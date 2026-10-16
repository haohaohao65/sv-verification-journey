// Scoreboard：按顺序配对 AXI 接受记录与 UART 完整帧/取消通知。
// 当前 Driver 一次只处理一帧，因此使用两个 mailbox 的队首顺序配对。
class scoreboard #(parameter DATA_WIDTH = 8);

    transaction #(DATA_WIDTH) tr_uart;
    transaction #(DATA_WIDTH) tr_axi;
    mailbox mb_uart_mon;
    mailbox mb_axi_mon;
    // checked 只统计做过数据比较的完整帧；passed/failed 是比较结果计数。
    // canceled 是累计取消数量，不是单笔记录的标志；单笔标志是 tr_uart.aborted。
    int checked = 0;
    int passed  = 0;
    int failed  = 0;

    int canceled = 0;  //取消比较标志，从uart_monitor处得到aborted = 1表示数据发送过程中触发复位，则加一，下面代码有体现；

    function new(mailbox mb_uart_mon, mailbox mb_axi_mon);
        this.mb_uart_mon = mb_uart_mon;
        this.mb_axi_mon  = mb_axi_mon;
    endfunction

    task run();

        forever begin
            // 两次 get 都会移除队首记录，mailbox 为空时阻塞。
            // 当前串行配对模型下可以先取任意一边，但 continue 之前必须消费对应的 AXI 记录。
            mb_uart_mon.get(tr_uart);
            mb_axi_mon.get(tr_axi);

            // 取消的帧不做数据比较；仍消费一笔预期，防止下一帧与旧预期错位。
            // 不清零 passed/failed，复位不能抹掉此前发现的错误。
            if (tr_uart.aborted) begin
                canceled++;
                $display("cancel:expected=%0h", tr_axi.s_axis_tdata);
                continue;
            end

            // 完整帧：比较串行解码数据与 AXI 实际接受的数据。
            // $error 记录错误并继续统计，最终由 tb 的 failed 检查决定失败结束。
            if (tr_uart.observed_data == tr_axi.s_axis_tdata) begin
                $display("pass:expected=%0h,observed=%0h", tr_axi.s_axis_tdata, tr_uart.observed_data);
                passed++;
            end
            else begin
                $error("error:expected=%0h,observed=%0h", tr_axi.s_axis_tdata, tr_uart.observed_data);
                failed++;
            end

            checked++;

        end

    endtask

endclass
