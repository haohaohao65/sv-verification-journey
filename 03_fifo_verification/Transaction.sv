class Transaction #(parameter DATA_WIDTH = 8,parameter DEPTH=16);

rand logic rst_n;
rand logic wr_en;
rand logic rd_en;
rand logic [DATA_WIDTH-1:0]wr_data;
logic [DATA_WIDTH-1:0]rd_data;
logic full;
logic empty;
logic [$clog2(DEPTH+1)-1:0] count;
bit rd_valid;

function void display(string name);
$display("%s:rst_n=%0d,wr_en=%0d,rd_en=%0d,wr_data=%0h,rd_data=%0h,full=%0d,empty=%0d,count=%0d",
          name,this.rst_n,this.wr_en,this.rd_en,this.wr_data,this.rd_data,this.full,this.empty,this.count);
endfunction

function Transaction #(DATA_WIDTH,DEPTH) copy();
Transaction #(DATA_WIDTH,DEPTH) t;
t=new();
t.rst_n=this.rst_n;
t.wr_en=this.wr_en;
t.rd_en=this.rd_en;
t.wr_data=this.wr_data;
t.rd_data=this.rd_data;
t.full=this.full;
t.empty=this.empty;
t.count=this.count;
return t;
endfunction

constraint c_rst{
    rst_n dist{
        0:=5,
        1:=95
    };
}

constraint c_en{
    wr_en dist{
        0:=20,
        1:=80
    };

    rd_en dist{
        0:=60,
        1:=40
    };
}

endclass