// Driver：把 mailbox 中的抽象记录转换为接口信号，并按场景插入复位。
// 当前每帧之后等待 busy 清零，是逐帧发送方式，不是连续 valid 的压力测试。
class driver #(parameter DATA_WIDTH = 8);

    transaction #(DATA_WIDTH) tr;
    mailbox mb_dri;
    // virtual interface 是真实接口实例的句柄；dri_if 限定 Driver 可使用的视图。
    virtual uart_if.dri_if u_if;

    function new(mailbox mb_dri, virtual uart_if.dri_if u_if);
        this.mb_dri = mb_dri;
        this.u_if   = u_if;
    endfunction

    task run();

        forever begin
            // get() 在 mailbox 为空时阻塞，拿到记录后才继续。
            mb_dri.get(tr);
            tr.display("driver");

            // 通过 clocking block 驱动；<= 是非阻塞赋值，不是数值比较。
            u_if.dri_cb.rst           <= tr.rst;
            u_if.dri_cb.s_axis_tdata  <= tr.s_axis_tdata;
            u_if.dri_cb.s_axis_tvalid <= tr.s_axis_tvalid;
            u_if.dri_cb.prescale      <= tr.prescale;

            // 初始/空闲复位：保持三个时钟，检查 TX 输出和状态，再释放复位。
            // !== 连 x/z 也参与比较，因此未知值不会被当作符合预期。
            if (tr.rst) begin
                repeat (3) @(u_if.dri_cb);

                if ((u_if.dri_cb.txd !== 1'b1) ||
                    (u_if.dri_cb.tx_busy !== 1'b0) ||
                    (u_if.dri_cb.s_axis_tready !== 1'b0))
                    $fatal(1, "Idle reset check failed");

                $display("Idle reset check passed");

                u_if.dri_cb.rst <= 1'b0;
                continue;
            end

            // continue 结束本轮 forever；回到 mailbox 取下一笔记录。
            if (!tr.s_axis_tvalid)
                continue;

            // valid 已被置为 1；至少等待一个采样事件，直到 ready 为 1，确认握手。
            // 握手前不推进数据；握手后撤销 valid，防止同一记录被重复接受。
            do
                @(u_if.dri_cb);
            while (!u_if.dri_cb.s_axis_tready);

            // 已完成 valid && ready 握手，本笔 transaction 结束
            u_if.dri_cb.s_axis_tvalid <= 0;

            // 同一发送记录携带复位延迟；队列后面的复位记录不能中断当前发送，
            // 因为当前 Driver 会先等待这一帧的 busy 结束才取下一笔记录。
            if (tr.reset_after_cycles > 0) begin
                repeat (tr.reset_after_cycles) @(u_if.dri_cb);

                // 防止延迟太长，实际已经发送完了
                if (u_if.dri_cb.tx_busy !== 1'b1)
                    $fatal(1, "Reset injection missed active transmission");

                u_if.dri_cb.rst <= 1'b1;
                repeat (3) @(u_if.dri_cb);

                if ((u_if.dri_cb.txd !== 1'b1) ||
                    (u_if.dri_cb.tx_busy !== 1'b0) ||
                    (u_if.dri_cb.s_axis_tready !== 1'b0))
                    $fatal(1, "Mid-frame reset check failed");

                $display("Mid-frame reset check passed");
                u_if.dri_cb.rst <= 1'b0;
            end

            // 普通帧等待发送结束；取消帧等待复位处理后的空闲，再取下一笔。
            do
                @(u_if.dri_cb);
            while (u_if.dri_cb.tx_busy);

        end

    endtask


//检查连续发送场景
    task run_continuous();

    bit [DATA_WIDTH - 1:0] data_list[4] =
    '{8'h00, 8'hFF, 8'h55, 8'hAA};

    @(u_if.dri_cb);
    u_if.dri_cb.prescale<=4;
    u_if.dri_cb.s_axis_tvalid<=0;
    u_if.dri_cb.s_axis_tdata<=0;
    u_if.dri_cb.rst<=1;

    repeat(3) begin
        @(u_if.dri_cb);
    end
    
   if((u_if.dri_cb.txd !== 1'b1)||
      (u_if.dri_cb.tx_busy !== 1'b0)||
      (u_if.dri_cb.s_axis_tready !== 1'b0))
      $fatal(1,"run_continuous rst failed");    //复位检查

      $display("run_continuous rst passed");

    u_if.dri_cb.rst<=0;

    @(u_if.dri_cb);

    u_if.dri_cb.prescale<=4;
    u_if.dri_cb.s_axis_tvalid<=1;


    foreach(data_list[i]) begin
        u_if.dri_cb.s_axis_tdata <= data_list[i];

        do
        @(u_if.dri_cb);
        while(u_if.dri_cb.s_axis_tready!==1);
    end

    u_if.dri_cb.s_axis_tvalid<=0;

    endtask

endclass
