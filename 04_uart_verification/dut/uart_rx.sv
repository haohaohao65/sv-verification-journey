module uart_rx #(
    parameter DATA_WIDTH = 8
)(
    uart_if.dut_if u_if
);

reg [DATA_WIDTH-1:0] m_axis_tdata_reg = 0;
reg m_axis_tvalid_reg = 0;

reg rxd_reg = 1;

reg busy_reg = 0;
reg overrun_error_reg = 0;
reg frame_error_reg = 0;

reg [DATA_WIDTH-1:0] data_reg = 0;
reg [18:0] prescale_reg = 0;
reg [3:0] bit_cnt = 0;

assign u_if.m_axis_tdata  = m_axis_tdata_reg;
assign u_if.m_axis_tvalid = m_axis_tvalid_reg;

assign u_if.rx_busy          = busy_reg;
assign u_if.rx_overrun_error = overrun_error_reg;
assign u_if.rx_frame_error   = frame_error_reg;

always @(posedge u_if.clk) begin
    if (u_if.rst) begin
        m_axis_tdata_reg  <= 0;
        m_axis_tvalid_reg <= 0;

        rxd_reg           <= 1;

        prescale_reg      <= 0;
        bit_cnt           <= 0;

        busy_reg          <= 0;
        overrun_error_reg <= 0;
        frame_error_reg   <= 0;
    end
    else begin

        rxd_reg <= u_if.rxd;

        overrun_error_reg <= 0;
        frame_error_reg   <= 0;

        if (u_if.m_axis_tvalid && u_if.m_axis_tready) begin
            m_axis_tvalid_reg <= 0;
        end

        if (prescale_reg > 0) begin
            prescale_reg <= prescale_reg - 1;
        end

        else if (bit_cnt > 0) begin

            // 检查 start bit
            if (bit_cnt > DATA_WIDTH + 1) begin

                if (!rxd_reg) begin
                    bit_cnt      <= bit_cnt - 1;
                    prescale_reg <= (u_if.prescale << 3) - 1;
                end
                else begin
                    bit_cnt      <= 0;
                    prescale_reg <= 0;
                end

            end

            // 接收 DATA_WIDTH 个数据位
            else if (bit_cnt > 1) begin

                bit_cnt      <= bit_cnt - 1;
                prescale_reg <= (u_if.prescale << 3) - 1;

                data_reg <= {
                    rxd_reg,
                    data_reg[DATA_WIDTH-1:1]
                };

            end

            // 检查 stop bit
            else if (bit_cnt == 1) begin

                bit_cnt <= bit_cnt - 1;

                if (rxd_reg) begin
                    m_axis_tdata_reg  <= data_reg;
                    m_axis_tvalid_reg <= 1;

                    overrun_error_reg <= m_axis_tvalid_reg;
                end
                else begin
                    frame_error_reg <= 1;
                end

            end
        end

        // 等待新的 start bit
        else begin

            busy_reg <= 0;

            if (!rxd_reg) begin

                prescale_reg <= (u_if.prescale << 2) - 2;
                bit_cnt      <= DATA_WIDTH + 2;
                data_reg     <= 0;

                busy_reg      <= 1;
            end

        end
    end
end

endmodule