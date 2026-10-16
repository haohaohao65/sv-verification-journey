// UART Monitor：按位中心采样串行 txd，检查帧格式，再提交数据或取消通知。
// 当前使用配置推算采样周期，不等于已经实现了独立的位宽自动检查。
class uart_monitor #(parameter DATA_WIDTH = 8);

    transaction #(DATA_WIDTH) tr;
    mailbox mb_uart_mon;
    mailbox mb_uart_cov;
    virtual uart_if.tx_mon_if u_if;
    int cnt;
    int half_bit_time;
    int bit_time;
    // received_data[0] 是起始位，[DATA_WIDTH:1] 是数据，最高位是停止位。
    // frame_valid 表示本轮未被复位中断，不是接口上的 AXI valid。
    logic [DATA_WIDTH + 1:0] received_data;
    bit frame_valid;

    function new(
        mailbox mb_uart_mon,
        mailbox mb_uart_cov,
        virtual uart_if.tx_mon_if u_if
    );
        this.mb_uart_mon = mb_uart_mon;
        this.mb_uart_cov = mb_uart_cov;
        this.u_if        = u_if;
    endfunction

    task run();

        // 每轮重新寻找一帧，清理上一帧的临时状态，并创建独立结果对象。
        forever begin
            cnt           = 0;
            received_data = 0;
            frame_valid   = 1;

            tr = new();

            // 等到复位明确为 0 且 txd 明确为 0，把该低电平作为候选起始位。
            // !== 是四态比较：x/z 不会误满足“已经找到起始位”的条件。
            do begin
                @(u_if.tx_uart_mon_cb);
            end while ((u_if.tx_uart_mon_cb.rst !== 1'b0) ||
                       (u_if.tx_uart_mon_cb.txd !== 1'b0));

            tr.prescale = u_if.tx_uart_mon_cb.prescale;

            // 左移 3 位相当于乘 8；单位是时钟个数，不是 ns。
            // 先等待半个位到起始位中心，再每隔一个位时间采一次。
            half_bit_time = (tr.prescale << 3) / 2;
            bit_time      = (tr.prescale << 3);

            // 等待起始位中心的过程也可能遇到复位，必须逐拍检查。
            // break 只退出当前循环；后面的统一提交分支负责发送取消通知。
            repeat (half_bit_time) begin
                @(u_if.tx_uart_mon_cb);

                if (u_if.tx_uart_mon_cb.rst) begin
                    frame_valid = 0;
                    break;
                end
            end

            // 起始位 + DATA_WIDTH 个数据位 + 停止位；UART 数据按 LSB-first 到达。
            repeat (DATA_WIDTH + 2) begin

                if (u_if.tx_uart_mon_cb.rst) begin
                    frame_valid = 0;
                    break;
                end

                received_data[cnt] = u_if.tx_uart_mon_cb.txd;

                cnt++;

                // 两次位中心之间逐拍等待并检查复位；最后采完停止位中心不再等整个位。
                if (cnt < DATA_WIDTH + 2) begin
                    repeat (bit_time) begin
                        @(u_if.tx_uart_mon_cb);

                        if (u_if.tx_uart_mon_cb.rst) begin
                            frame_valid = 0;
                            break;
                        end
                    end
                end

                if (!frame_valid)
                    break;

            end

            // 三个 if 是独立阶段：后续等待可能改变 frame_valid，提交前必须重新判断。
            // 1. 已经采完，先检查起始位和停止位中心
            if (frame_valid) begin
                // 帧格式错误立即 fatal；不能因后面发生复位而掩盖已经采到的格式错误。
                if (received_data[0] !== 1'b0)
                    $fatal(1, "Start bit error");

                if (received_data[DATA_WIDTH + 1] !== 1'b1)
                    $fatal(1, "Stop bit error");
            end

            // 2. 等待停止位剩余的半个位时间，仍然逐拍检查复位
            if (frame_valid) begin
                repeat (half_bit_time) begin
                    @(u_if.tx_uart_mon_cb);

                    if (u_if.tx_uart_mon_cb.rst) begin
                        frame_valid = 0;
                        break;
                    end
                end
            end

            // 3. 等待结束后，重新判断：提交完整帧还是发送取消通知
            if (frame_valid) begin
                // 去掉起始位和停止位，留下解码数据；只在完整帧路径上采功能覆盖。
                tr.observed_data = received_data[DATA_WIDTH:1];

                $display("observed_data=%0h", tr.observed_data);

                mb_uart_mon.put(tr);
                mb_uart_cov.put(tr.copy());
            end
            else begin
                // 半帧也必须通知 Scoreboard，让它消费对应的 AXI 预期；不送 UART Coverage。
                tr.aborted = 1;
                mb_uart_mon.put(tr);
                $display("UART frame aborted by reset");
            end

        end

    endtask



// 当前逐帧发送方式下，检查 FF 帧的起始位宽度。
task check_ff_start();
    int expected_cycles;
    int actual_cycles;

    forever begin
        @(u_if.tx_uart_mon_cb);

        // 复位期间不开始检查。
        if (u_if.tx_uart_mon_cb.rst !== 1'b0)
            continue;

        // 只选择成功握手的 FF 数据。
        if ((u_if.tx_axi_mon_cb.s_axis_tvalid !== 1'b1) ||
            (u_if.tx_axi_mon_cb.s_axis_tready !== 1'b1) ||
            (u_if.tx_axi_mon_cb.s_axis_tdata !== 8'hFF))
            continue;

        expected_cycles = u_if.tx_uart_mon_cb.prescale * 8;
        actual_cycles = 0;

       // 如果这一拍仍是空闲高电平，再等一拍采到 DUT 的更新。
       if (u_if.tx_uart_mon_cb.txd === 1'b1)
       @(u_if.tx_uart_mon_cb);

       // 等待期间如果发生复位，取消本次测量。
       if (u_if.tx_uart_mon_cb.rst !== 1'b0)
       continue;

       // 当前 DUT 应已进入起始位，否则明确报错。
       if (u_if.tx_uart_mon_cb.txd !== 1'b0)
       $fatal(1, "FF start bit not found after handshake");

        // 不固定等待 expected_cycles，而是等到实际低电平结束。
        while (u_if.tx_uart_mon_cb.txd === 1'b0) begin
            @(u_if.tx_uart_mon_cb);
            actual_cycles++;

            if (u_if.tx_uart_mon_cb.rst !== 1'b0)
                break;
        end

        // 复位中断了测量，不能按完整起始位判定位宽。
        if (u_if.tx_uart_mon_cb.rst !== 1'b0) begin
            $display("FF start timing check canceled by reset");
            continue;
        end

        // 排除低电平结束后变成 x/z 的情况。
        if (u_if.tx_uart_mon_cb.txd !== 1'b1)
            $fatal(1, "Unknown TXD during FF start timing check");

        if (actual_cycles != expected_cycles)
            $fatal(1,
                   "FF start width error: expected=%0d actual=%0d",
                   expected_cycles, actual_cycles);

        $display("FF start width passed: expected=%0d actual=%0d",
                 expected_cycles, actual_cycles);
    end
endtask


// 针对当前 8 位 55 场景，检查起始位和八个数据位。
task check_55_width();
    int expected_cycles;
    int actual_cycles;
    int segment_index;
    logic current_level;
    bit timing_aborted;

    forever begin
        @(u_if.tx_uart_mon_cb);

        if (u_if.tx_uart_mon_cb.rst !== 1'b0)
            continue;

        // 只检查成功握手的 55。
        if ((u_if.tx_axi_mon_cb.s_axis_tvalid !== 1'b1) ||
            (u_if.tx_axi_mon_cb.s_axis_tready !== 1'b1) ||
            (u_if.tx_axi_mon_cb.s_axis_tdata !== 8'h55))
            continue;

        expected_cycles = u_if.tx_uart_mon_cb.prescale * 8;
        segment_index = 0;
        timing_aborted = 0;

        // 与 FF 检查一样，必要时再等一拍看到起始位。
        if (u_if.tx_uart_mon_cb.txd === 1'b1)
            @(u_if.tx_uart_mon_cb);

        if (u_if.tx_uart_mon_cb.rst !== 1'b0)
            continue;

        if (u_if.tx_uart_mon_cb.txd !== 1'b0)
            $fatal(1, "55 start bit not found after handshake");

        current_level = 1'b0;

        // 起始位 + 八个数据位，共九段。
        repeat (DATA_WIDTH + 1) begin
            actual_cycles = 0;

            // 电平没变，就继续测量这一段。
            while (u_if.tx_uart_mon_cb.txd === current_level) begin
                @(u_if.tx_uart_mon_cb);
                actual_cycles++;

                if (u_if.tx_uart_mon_cb.rst !== 1'b0) begin
                    timing_aborted = 1;
                    break;
                end
            end

            // 上面的 break 只退出 while；
            // 这里再退出外层 repeat，取消后续位的检查。
            if (timing_aborted)
                break;

            // 下一段必须是相反电平，不能是 x/z。
            if (u_if.tx_uart_mon_cb.txd !== ~current_level)
                $fatal(1, "Unknown TXD during 55 width check");

            if (actual_cycles != expected_cycles)
                $fatal(1,
                       "55 width error: segment=%0d expected=%0d actual=%0d",
                       segment_index, expected_cycles, actual_cycles);

            $display("55 width passed: segment=%0d expected=%0d actual=%0d",
                     segment_index, expected_cycles, actual_cycles);

            // 当前边沿既结束上一段，也开始下一段。
            current_level = u_if.tx_uart_mon_cb.txd;
            segment_index++;
        end

        if (timing_aborted)
            $display("55 width check canceled by reset");
    end
endtask

endclass
