`include "Transaction.sv"

module tb_tr;

Transaction tr;

initial begin
    tr=new();

    repeat(10) begin
        assert(tr.randomize());
        tr.display();
    end
end


endmodule