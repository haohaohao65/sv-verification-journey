// Generator：选择测试场景并生成 Transaction，通过 mailbox 交给 Driver。
// 它描述“要测什么”，不直接操作接口，也不等待 UART 帧完成。
class generator #(parameter DATA_WIDTH = 8);

    transaction #(DATA_WIDTH) tr;
    mailbox mb_dri;
    // expected_frames 是计划发送的有效记录数，包含之后可能被复位取消的帧。
    // expected_canceled 是测试要求的取消数，不能从 Scoreboard 的实际结果反推。
    int expected_frames   = 0;
    int expected_canceled = 0;
    bit done              = 0;

    // 四种定向数据：全 0、全 1，以及两种相邻位交替的数据模式。
    bit [DATA_WIDTH - 1:0] test_data[4] =
        '{8'h00, 8'hFF, 8'h55, 8'hAA};

    bit [DATA_WIDTH - 1:0] test_byte;

    string test_name = "normal";

    // this.mb_dri 是对象成员；右边 mb_dri 是传入的 mailbox 句柄。
    function new(mailbox mb_dri);
        this.mb_dri = mb_dri;
    endfunction

    // 读取 +TEST=名字，检查名字，再依次生成初始复位和三组数据。
    task run();

        if (!$value$plusargs("TEST=%s", test_name))  //没有取到test_name则按照normal情形测试；
            test_name = "normal";

        $display("Running TEST=%s", test_name);  //显示按照什么模式测试

        // 防止名字拼错后悄悄退化为正常测试；未知名字立即终止仿真。
        if ((test_name != "normal") &&
            (test_name != "reset_start") &&
            (test_name != "reset_data") &&
            (test_name != "reset_stop") &&
            (test_name != "reset_stop_late") &&
            (test_name != "reset_last") &&
            (test_name != "continuous") )
        begin
            $fatal(1, "Unknown TEST=%s", test_name);
        end

        // 当前 normal 不取消帧，其余五个合法测试各取消一帧；新增测试时要重新定义预期。
        if (test_name == "normal")
            expected_canceled = 0;
        else
            expected_canceled = 1;

        
        if(test_name == "continuous") begin
        expected_frames = 4;
        expected_canceled = 0;
        done = 1;
        return;
        end

        // 初始复位记录不是待发送帧，不增加 expected_frames。
        tr               = new();
        tr.rst           = 1'b1;
        tr.s_axis_tvalid = 1'b0;
        tr.s_axis_tdata  = 8'h00;
        tr.prescale      = 4;
        mb_dri.put(tr);  //产生复位

        // 第一组：prescale=1，每位名义上占 8 个时钟；遍历数组下标 i=0/1/2/3。
        // 每次 new() 产生新对象，避免放进 mailbox 的旧记录被后续赋值覆盖。
        // local::test_byte 指向调用 randomize() 所在作用域的变量，而非 tr 的成员。
        // assert 检查求解是否成功；失败时 $fatal 停止，避免使用未成功随机化的数据。
        foreach (test_data[i]) begin

            test_byte = test_data[i];

            tr = new();

            assert (tr.randomize() with {
                rst           == 0;
                s_axis_tvalid == 1;
                s_axis_tdata  == local::test_byte;
                prescale      == 1;
            }) else $fatal(1, "Generator randomization failed");

            if (!tr.rst && tr.s_axis_tvalid) begin
                expected_frames++;
            end

            tr.display("generator");
            mb_dri.put(tr);
        end

        foreach (test_data[i]) begin

            test_byte = test_data[i];

            tr = new();

            assert (tr.randomize() with {
                rst           == 0;
                s_axis_tvalid == 1;
                s_axis_tdata  == local::test_byte;
                // 第二组固定 prescale=4，每位名义上占 32 个时钟。
                prescale      == 4;
            }) else $fatal(1, "Generator randomization failed");

            // 第二组的 55 帧插入复位；后面还有数据，可检查取消后是否恢复对齐。
            // 延迟以握手后的时钟数计：8 在起始位，80 在数据位，300/308 在停止位。
            // 308 位于停止位中心采样之后，用于检查 Monitor 的后半位复位检测。
            if (i == 2) begin
                if (test_name == "reset_start")
                    tr.reset_after_cycles = 8;
                else if (test_name == "reset_data")
                    tr.reset_after_cycles = 80;
                else if (test_name == "reset_stop")
                    tr.reset_after_cycles = 300;
                else if (test_name == "reset_stop_late")
                    tr.reset_after_cycles = 308;
            end

            if (!tr.rst && tr.s_axis_tvalid) begin
                expected_frames++;
            end

            tr.display("generator");
            mb_dri.put(tr);
        end

        foreach (test_data[i]) begin

            test_byte = test_data[i];

            tr = new();

            assert (tr.randomize() with {
                rst           == 0;
                s_axis_tvalid == 1;
                s_axis_tdata  == local::test_byte;
                // 第三组固定 prescale=8，每位名义上占 64 个时钟。
                prescale      == 8;
            }) else $fatal(1, "Generator randomization failed");

            // 最后一帧 AA 取消后没有下一帧；专门检查结束流程不会漏掉取消通知。
            if ((test_name == "reset_last") && (i == 3))
                tr.reset_after_cycles = 80;

            if (!tr.rst && tr.s_axis_tvalid) begin
                expected_frames++;
            end

            tr.display("generator");
            mb_dri.put(tr);
        end

        done = 1;  //done=1 表示所有激励已经生成，expected_frames 的最终值确定了。它不代表 DUT 已经发送完。

    endtask

endclass
