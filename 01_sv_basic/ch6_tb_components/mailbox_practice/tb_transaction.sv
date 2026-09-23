`include "Transaction.sv"

module tb_tr;

    Transaction tr1;
    Transaction tr2;
    Transaction tr3;

    Transaction a;
    Transaction b;
    Transaction c;

    mailbox mb;

    initial begin

        mb = new();

        tr1 = new(10);
        tr2 = new(20);
        tr3 = new(30);

        mb.put(tr1);
        mb.put(tr2);
        mb.put(tr3);// 把三个 transaction 放进 mailbox
        

        mb.get(a);
        mb.get(b);
        mb.get(c);// 从 mailbox 取出三个 transaction


        a.display();
        b.display();
        c.display();// 分别 display

        a.data = 999;
       a.display();
       tr1.display();


    end

endmodule