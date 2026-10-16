// Testbench 顶层：实例化接口和 DUT，创建 Environment，汇总并判定结果。
// 当前只实例化 UART TX；共享接口的 RX 信号尚未连接 RX DUT，可能显示 x。
module tb #(parameter DATA_WIDTH = 8);

    // 每 5 ns 翻转一次，完整时钟周期为 10 ns。
    logic clk;
    initial clk = 0;
    always #5ns clk = ~clk;

    // 接口把 DUT 与验证组件连接起来；参数传递保持接口与 DUT 的数据宽度一致。
    uart_if #(.DATA_WIDTH(DATA_WIDTH)) u_if(clk);

    uart_tx #(.DATA_WIDTH(DATA_WIDTH)) dut(
        .u_if(u_if)
    );

    environment #(DATA_WIDTH) env;

    // 主测试线程：创建对象 -> 跑测试并等待完成 -> 打印 -> 检查 -> finish。
    initial begin
        // 同一个真实接口分别以 Driver 和 Monitor 的 modport 视图传给 Environment。
        env = new(u_if, u_if);

        env.run();

        // 等待 DUT 完成剩余停止位并回到空闲
        do begin
            @(u_if.tx_uart_mon_cb);
        end while (u_if.tx_uart_mon_cb.tx_busy !== 1'b0);

        // Expected 是生成目标；AXI 是接受数；UART/Checked 只包含完整帧；Canceled 单独计数。
        $display(
            "Expected=%0d AXI=%0d UART=%0d Checked=%0d Pass=%0d Fail=%0d Canceled=%0d",
            env.gen.expected_frames,
            env.cov.axi_samples,
            env.cov.uart_samples,
            env.sco.checked,
            env.sco.passed,
            env.sco.failed,
            env.sco.canceled
        );

        // get_coverage() 已返回 0~100 的百分数；%0.2f 保留两位小数，%% 打印百分号。
        // coverpoint/cross 的覆盖率不能代替 Scoreboard 的数据正确性检查。
        $display("AXI data coverage = %0.2f%%",
            env.cov.axi_cg.cg_data.get_coverage());

        $display("UART prescale coverage = %0.2f%%",
            env.cov.uart_cg.cp_prescale.get_coverage());

        $display("UART data x prescale coverage = %0.2f%%",
            env.cov.uart_cg.data_x_prescale.get_coverage());  //打印覆盖率

        // 数据比较出现过错误，即使其他帧通过，也不能成功结束。
        if (env.sco.failed != 0)
            $fatal(1, "Data comparison failed");

        $display("Cancel check: expected=%0d actual=%0d",
            env.gen.expected_canceled,
            env.sco.canceled);

        // 实际取消数必须符合测试计划，防止意外取消或应该取消却未取消被计数条件掩盖。
        if (env.sco.canceled != env.gen.expected_canceled)
            $fatal(1, "Cancel count mismatch: expected=%0d actual=%0d",
                env.gen.expected_canceled,
                env.sco.canceled);

        // 正常结束仿真；脚本的 -onfinish stop 会保留窗口供查看日志和波形。
        $finish;

    end

    initial begin
        // 独立看门狗与主线程并行；等待条件卡住时，约 100 us 后明确报错。
        // $fatal(1, ...) 的 1 是结束诊断级别，不是“发生了一个错误”的计数。
        repeat (10000) @(posedge clk);
        $fatal(1, "TX test timeout");
    end

endmodule
