class Transaction;

rand bit write;
rand bit [7:0]addr;
rand bit[7:0]data;

constraint tr_c{
    addr inside {[10:100]};
    write -> data!=0;
    write dist{
        0 := 30,
        1 := 70
    };
}

function void display();
$display("write=%0d,addr=%0d,data=%0d",this.write,this.addr,this.data);  //记得加.this更清晰
endfunction

endclass