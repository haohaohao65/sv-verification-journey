class Transaction;

rand logic [7:0]a;
rand logic [7:0]b;
rand logic [1:0]op;
logic [7:0]result;

function void display(string name);
$display("%s:a=%0d,b=%0d,op=%0d,result=%0d",name,this.a,this.b,this.op,this.result);
endfunction

constraint op_c{
    this.op inside{[0:3]};
}

constraint a_c{
    a dist {
        0 :=10,
        [1:254] :/80,
        255 := 10
    };
}            //给a随机化分配权重；

function Transaction clone();
    Transaction t;
    t = new();

    t.a = this.a;
    t.b = this.b;
    t.op = this.op;
    t.result = this.result;

    return t;
endfunction

endclass