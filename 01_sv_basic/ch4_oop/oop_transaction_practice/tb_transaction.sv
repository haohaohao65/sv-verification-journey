`include "Transaction.sv"
module tb_tr;

Transaction tr;
ReadTransaction rd;
ReadTransaction copy_tr;

initial begin
rd = new(0, 0);
    tr = rd;
tr.display();

#10ns;

$cast(rd,tr);
rd.addr=1;
tr.display();

#10ns;
$cast(copy_tr, tr.copy());

#10ns;

copy_tr.display();
tr.display();

#10ns;

copy_tr.addr = 999;

#10ns;

copy_tr.display();
tr.display();

end

endmodule