class Transaction;

    int data;

    function new(int data);
        this.data = data;
    endfunction

    function void display();
        $display("data=%0d", this.data);
    endfunction

endclass