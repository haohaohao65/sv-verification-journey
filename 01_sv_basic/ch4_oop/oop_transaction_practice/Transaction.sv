class Transaction;
 int data;

function new(int data);
this.data=data;
endfunction

 virtual function void display();
 $display ("Transaction:data=%0d",this.data);
 endfunction

virtual function Transaction copy();
 Transaction tr=new(this.data);
tr.data=this.data;
copy = tr;  //或是return=tr，不然只是单纯复制，外面找不到句柄。
//copy() 里面不用复制 virtual function
 endfunction

endclass


class ReadTransaction extends Transaction;
int addr;

function new(int data,int addr);
super.new(data);   //这里可不可以用this.data=data?  子类初始化父类成员，优先使用 super.new()
this.addr=addr;
endfunction

function void display();
$display ("ReadTransaction:data=%0d,addr=%0d",this.data,this.addr);
endfunction

function Transaction copy();//这里是ReadTransaction copy()还是Transaction copy()？
ReadTransaction tr = new(this.data, this.addr);;
copy=tr;
endfunction

endclass