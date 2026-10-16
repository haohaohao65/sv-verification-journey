module uart #(
    parameter DATA_WIDTH = 8
)(
    uart_if.dut_if u_if
);

uart_tx #(
    .DATA_WIDTH(DATA_WIDTH)
) uart_tx_inst (
    .u_if(u_if)
);

uart_rx #(
    .DATA_WIDTH(DATA_WIDTH)
) uart_rx_inst (
    .u_if(u_if)
);

endmodule