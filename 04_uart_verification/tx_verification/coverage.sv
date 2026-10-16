// Coverage：记录发生过哪些场景，不判断数据正确性；正确性由 Scoreboard 检查。
// AXI 覆盖已接受输入，UART 覆盖完整输出，取消的半帧不采 UART 覆盖。
class coverage #(parameter DATA_WIDTH = 8);

    transaction #(DATA_WIDTH) tr_0;
    transaction #(DATA_WIDTH) tr_1;
    logic rst;
    logic [DATA_WIDTH - 1:0] s_axis_tdata;
    logic s_axis_tvalid;
    logic s_axis_tready;
    logic [15:0] prescale;
    // 样本计数供 Environment 等待完成；百分比由 covergroup 的 bin 命中情况决定。
    int axi_samples  = 0;
    int uart_samples = 0;
    logic [DATA_WIDTH - 1:0] observed_data;

    // 显式 bins 定义四个定向目标；100% 不代表所有 256 个字节都测试过。
    covergroup axi_cg();

        cg_data: coverpoint s_axis_tdata {
            bins data_00 = {8'h00};
            bins data_ff = {8'hFF};
            bins data_55 = {8'h55};
            bins data_aa = {8'hAA};
        }

    endgroup

    // UART 的数据和 prescale 都来自同一帧，不能拿另一个线程最新的 AXI 数据来配对。
    covergroup uart_cg;
        cp_prescale: coverpoint prescale {
            bins p1 = {1};
            bins p4 = {4};
            bins p8 = {8};
        }

        cp_data: coverpoint observed_data {
            bins data_00 = {8'h00};
            bins data_ff = {8'hFF};
            bins data_55 = {8'h55};
            bins data_aa = {8'hAA};
        }

        // 四个数据 bin 与三个 prescale bin 自动组合成 12 个交叉 bin。
        // normal 应命中 12 个；当前单帧取消测试只命中 11 个，91.67% 是预期缺口。
        data_x_prescale: cross cp_data, cp_prescale;

    endgroup

    mailbox mb_uart_cov;
    mailbox mb_axi_cov;

    // covergroup 也需要 new() 创建实例，之后才能调用 sample()。
    function new(mailbox mb_uart_cov, mailbox mb_axi_cov);
        this.mb_uart_cov = mb_uart_cov;
        this.mb_axi_cov  = mb_axi_cov;
        axi_cg           = new();
        uart_cg          = new();
    endfunction

    // 接收握手记录，先更新 coverpoint 使用的成员变量，再手动 sample()。
    task sample_axi();
        forever begin
            mb_axi_cov.get(tr_1);
            s_axis_tdata = tr_1.s_axis_tdata;
            axi_cg.sample();
            axi_samples++;
        end
    endtask

    // 接收完整 UART 帧；两个赋值完成后一次性采样，保证 cross 对应同一笔记录。
    task sample_uart();
        forever begin
            mb_uart_cov.get(tr_0);
            prescale      = tr_0.prescale;
            observed_data = tr_0.observed_data;
            uart_cg.sample();
            uart_samples++;
        end
    endtask

    // 两条 mailbox 独立消费；fork...join 让采样线程并行运行。
    // 两个 forever 不自然结束，最终由 Environment 的 disable fork 停止。
    task run();
        fork
            sample_axi();
            sample_uart();
        join
    endtask

endclass
