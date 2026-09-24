class Transaction;

rand int data;

constraint data_c{
    data inside {[0:100]};
}

function void display(string name);
$display("%s:data=%0d",name,data);
endfunction

endclass