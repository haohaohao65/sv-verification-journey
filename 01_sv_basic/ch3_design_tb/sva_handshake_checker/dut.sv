module handshake_dut (
    handshake_if.dut_mp h_if
);

    logic [1:0] busy_cnt;

    assign h_if.ready = (busy_cnt == 0);

    always @(posedge h_if.clk) begin
        if (!h_if.rst_n) begin
            busy_cnt <= 0;
        end
        else if (h_if.valid && h_if.ready) begin
            busy_cnt <= 2;
        end
        else if (busy_cnt != 0) begin
            busy_cnt <= busy_cnt - 1;
        end
    end

endmodule