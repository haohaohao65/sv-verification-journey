module tb_mux2to1;
logic a;
logic b;
logic sel;
logic y;

dut_mux2to1 dut(
    .a(a),
    .b(b),
    .sel(sel),
    .y(y)
);

initial begin
    a=0;
    b=0;
    sel=0;
    $display ("y=%0d",y);
    #10ns begin a=0;
    b=1;
    sel=0;
    end
    $display ("y=%0d",y);
    #10ns begin
    a=0;
    b=1;
    sel=1;
    end
    $display ("y=%0d",y);
    #10ns begin
    a=1;
    b=0;
    sel=1;
    end
    $display ("y=%0d",y);
end

endmodule