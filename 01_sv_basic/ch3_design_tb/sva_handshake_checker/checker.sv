module sva_checker(handshake_if.checker_mp h_if);

property rule1;
    @(posedge h_if.clk)
    disable iff(!h_if.rst_n)
h_if.valid&&!h_if.ready |=> h_if.valid;
endproperty

property rule2;
@(posedge h_if.clk)
    disable iff(!h_if.rst_n)
    h_if.valid&&!h_if.ready |=> $stable(h_if.data);
endproperty

property rule3;
    @(posedge h_if.clk)
    h_if.valid && !h_if.ready
    |-> (h_if.valid && !h_if.ready)[*3];
endproperty

assert property(rule3);

assert property(rule3);


assert property(rule1);
assert property(rule2);

endmodule