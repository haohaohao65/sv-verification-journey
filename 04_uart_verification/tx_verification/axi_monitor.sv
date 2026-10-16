// AXI Monitor：只观察 AXI-Stream 握手，不驱动信号。
// 记录的是 DUT 实际接受的数据，而不是 Generator 曾经打算发送的数据。
class axi_monitor #(parameter DATA_WIDTH = 8);

    transaction #(DATA_WIDTH) tr;
    virtual uart_if.tx_mon_if u_if;
    mailbox mb_axi_mon;
    mailbox mb_axi_cov;

    function new(
        mailbox mb_axi_mon,
        mailbox mb_axi_cov,
        virtual uart_if.tx_mon_if u_if
    );
        this.mb_axi_mon = mb_axi_mon;
        this.mb_axi_cov = mb_axi_cov;
        this.u_if       = u_if;
    endfunction

    task run();

        forever begin

            @(u_if.tx_axi_mon_cb);

            // 复位期间跳过采样，不把复位记录当成一次有效数据接受。
            if (u_if.tx_axi_mon_cb.rst)
                continue;

            // 同一拍 valid 和 ready 都成立才记录一次传输；仅有 valid 不算握手。
            if (u_if.tx_axi_mon_cb.s_axis_tvalid &&
                u_if.tx_axi_mon_cb.s_axis_tready) begin

                tr = new();

                tr.rst           = u_if.tx_axi_mon_cb.rst;
                tr.s_axis_tdata  = u_if.tx_axi_mon_cb.s_axis_tdata;
                tr.s_axis_tvalid = u_if.tx_axi_mon_cb.s_axis_tvalid;
                tr.s_axis_tready = u_if.tx_axi_mon_cb.s_axis_tready;
                // The shared UART interface exposes independent TX/RX status.
                // This is the TX-side monitor, so preserve the transaction's
                // existing "busy" field by sampling tx_busy.
                tr.busy = u_if.tx_axi_mon_cb.tx_busy;

                // 一份送 Scoreboard 作为预期，独立副本送 Coverage 统计输入覆盖。
                mb_axi_mon.put(tr);
                mb_axi_cov.put(tr.copy());
            end

        end

    endtask

endclass
