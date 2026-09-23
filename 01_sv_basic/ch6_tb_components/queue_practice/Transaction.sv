class Transaction;

int data;

function new(int data);  //这里中间不加void；
this.data=data;
endfunction

function void display();
$display("data=%0d",this.data);
endfunction

endclass