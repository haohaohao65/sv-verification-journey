`include "Transaction.sv"

module tb_tr;

Transaction tr1;
Transaction tr2;
Transaction tr3;
Transaction q[$];

Transaction a;
Transaction b;
Transaction c;

initial begin
    tr1=new(10);
    tr2=new(20);
    tr3=new(30);

#10ns;

    q.push_back(tr1);
    #10ns;
    q.push_back(tr2);
    #10ns;
    q.push_back(tr3);

#10ns;

    a=q.pop_front();
    a.display();

    #10ns;
    b=q.pop_front();
    b.display();

    #10ns;
    c=q.pop_front();
    c.display();

end

endmodule