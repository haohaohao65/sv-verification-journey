module Transaction_Data_Manager;

typedef enum{
    READ,
    WRITE,
    IDLE
} op_t;

typedef struct{
    bit [7:0] addr;
    bit [31:0] data;
    op_t op;
} transaction_t;

transaction_t transactions[];

transaction_t Transactions_addr10[];
int Transactions_addr20_index[];
transaction_t Transactions_unique_addr[];
transaction_t First_transaction_data;
int a[6];
int b[6];
op_t c[6];

initial begin
    transactions=new[6];
    a='{10,20,10,30,20,40};
    b='{100,200,300,400,500,600};
    c='{READ,WRITE,READ,WRITE,READ,IDLE};
    foreach(transactions[i]) begin
        transactions[i].addr=a[i];
        transactions[i].data=b[i];
        transactions[i].op=c[i];
    end

    Transactions_addr10=transactions.find() with (item.addr==10);
    Transactions_addr20_index=transactions.find_index() with (item.addr==20);
  First_transaction_data = transactions[3];
    Transactions_unique_addr=transactions.unique() with (item.addr);

    $display("Transactions_addr10=%p,Transactions_addr20_index=%p,First_transaction_data=%p,Transactions_unique_addr=%p",Transactions_addr10,Transactions_addr20_index,First_transaction_data,Transactions_unique_addr);
end

transaction_t tr_queue[$];

initial begin
    tr_queue=transactions;
    tr_queue.pop_front();
    tr_queue.pop_back();
    $display ("tr_queue.size=%0d",tr_queue.size());
end

transaction_t memory[int];
initial begin
    foreach(transactions[i]) begin
    memory[transactions[i].addr]=transactions[i];
end

foreach(memory[i])begin
    $display ("addr=%0d,data=%0d,op=%0d",memory[i].addr,memory[i].data,memory[i].op);
end
end

string message;

initial begin
    message="SV Data Types Practice";
    $display ("message=%s,message's length=%0d",message,message.len());
end

endmodule