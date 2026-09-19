module subroutine_practice;

typedef struct{
    int id;
    int data;
} transaction_t;

function int d1(int a);
if(a>100)
return 1;
else
return 0;
endfunction

function int d2(int a);
return a*2;
endfunction

task d3(input transaction_t a,output int b);
b=a.data*2;
endtask

task automatic d4(ref transaction_t a);
a.data=a.data+50;
endtask

bit result1;
int result2;
int task_result;


initial begin
    transaction_t transaction;
    transaction.id=1;
    transaction.data=80;

    result1=d1(transaction.data);
    $display("result1=%0d",result1);

    result2=d2(transaction.data);
    $display("result2=%0d",result2);

    d3(transaction,task_result);
    $display("task_result=%0d",task_result);

    d4(transaction);
    $display("data=%0d,id=%0d",transaction.data,transaction.id);
end

endmodule