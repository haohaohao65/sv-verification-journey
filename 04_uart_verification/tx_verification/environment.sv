// Environment：创建并连接各组件，启动并行任务，等待测试处理完毕。
// 数据流：Generator -> Driver -> DUT；AXI/UART Monitor -> Scoreboard 和 Coverage。
class environment #(parameter DATA_WIDTH = 8);

    generator #(DATA_WIDTH) gen;
    driver #(DATA_WIDTH) dri;
    axi_monitor #(DATA_WIDTH) a_mon;
    uart_monitor #(DATA_WIDTH) u_mon;
    scoreboard #(DATA_WIDTH) sco;
    coverage #(DATA_WIDTH) cov;
    // 五条独立队列：激励一条，Scoreboard 输入两条，Coverage 输入两条。
    // 同一个 mailbox 不是广播通道；两个消费者 get 会分走记录，因此分别建队列。
    mailbox mb_dri;
    mailbox mb_uart_mon;
    mailbox mb_axi_mon;
    mailbox mb_axi_cov;
    mailbox mb_uart_cov;
    virtual uart_if.dri_if dri_vif;
    virtual uart_if.tx_mon_if mon_vif;

    // 先建 mailbox，再把同一条通道的句柄传给对应生产者和消费者。
    function new(
        virtual uart_if.dri_if dri_vif,
        virtual uart_if.tx_mon_if mon_vif
    );
        mb_dri      = new();
        mb_uart_mon = new();
        mb_axi_cov  = new();
        mb_axi_mon  = new();
        mb_uart_cov = new();
        // 保存接口句柄供 run() 使用；只传给子组件不会自动初始化 Environment 的成员。
        this.dri_vif = dri_vif;
        this.mon_vif = mon_vif;
        gen          = new(mb_dri);
        dri          = new(mb_dri, dri_vif);
        cov          = new(mb_uart_cov, mb_axi_cov);
        a_mon        = new(mb_axi_mon, mb_axi_cov, mon_vif);
        u_mon        = new(mb_uart_mon, mb_uart_cov, mon_vif);
        sco          = new(mb_uart_mon, mb_axi_mon);
    endfunction



    task run();
        
        gen.run();

        if(gen.test_name == "continuous") begin
        fork
            dri.run_continuous();
            a_mon.run();
            u_mon.run();
            u_mon.check_ff_start();
            u_mon.check_55_width();
            sco.run();
            cov.run();
        join_none
        end

        else begin
        // fork...join_none 启动六个并行任务，父线程不等待它们结束，继续执行后面的 wait。
        // Driver/Monitor/Scoreboard 是长期循环，不能依靠普通 join 自然返回。
        fork
            dri.run();
            a_mon.run();
            u_mon.run();
            u_mon.check_ff_start();
            u_mon.check_55_width();
            sco.run();
            cov.run();
        join_none
        end

        // 先等生成结束，确保 expected_frames 的最终值已确定；这不代表 DUT 发送结束。
        wait (gen.done == 1);

        // 当前逐帧场景要求：输入都被接受；每笔记录要么完整采样/比较，要么被取消。
        // 取消帧不增加 UART Coverage 和 checked，因此用 canceled 补足处理数量。
        // 这是计数完成条件，不是正确性判定；tb 还会检查 failed 和预期取消数。
        wait (cov.axi_samples >= gen.expected_frames &&
              cov.uart_samples + sco.canceled >= gen.expected_frames &&
              sco.checked + sco.canceled >= gen.expected_frames);

        // 最后一帧取消通知可能早于 Driver 完成三拍复位检查。
        // 必须等复位释放且 busy 清零，避免 disable fork 提前杀掉 Driver。
        do begin
            @(mon_vif.tx_uart_mon_cb);
        end while ((mon_vif.tx_uart_mon_cb.rst !== 1'b0) ||
                   (mon_vif.tx_uart_mon_cb.tx_busy !== 1'b0));

        // 停止本次 run 启动的剩余子线程，随后返回 tb 打印结果。
        disable fork;

    endtask

endclass
