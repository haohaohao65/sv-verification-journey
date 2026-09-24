class Transaction;

rand logic [7:0]a;
rand logic [7:0]b;

function void display(string name);
$display("%s:a=%0d,b=%0d",name,this.a,this.b);
endfunction

endclass