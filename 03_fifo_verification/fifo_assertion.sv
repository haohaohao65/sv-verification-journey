module fifo_assertion#(DATA_WIDTH=8,DEPTH=16) (fifo_if f_if);

assert property(@(posedge f_if.clk)
      !f_if.rst_n |=> f_if.count==0
);

assert property(@(posedge f_if.clk)
      f_if.count <= DEPTH
);

assert property(@(posedge f_if.clk)
      f_if.count==0 |->f_if.empty
);

assert property(@(posedge f_if.clk)
      f_if.count==DEPTH |->f_if.full
);

assert property(@(posedge f_if.clk)
      f_if.full |-> !(!f_if.full && f_if.wr_en)
);

assert property(@(posedge f_if.clk)
      !f_if.full && f_if.wr_en && (!f_if.rd_en || f_if.empty) |=> f_if.count==($past(f_if.count)+1)
);

endmodule