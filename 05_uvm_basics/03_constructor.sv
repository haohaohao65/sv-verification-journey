// 练习 3：构造函数
// constructor = 构造函数，init = initialization（初始化），start_value = 起始值。
// 构造函数在 new() 创建对象时自动执行，SystemVerilog 中名字固定为 new。

class counter_with_init;
    int count = 0;

    // 构造函数的形式：
    // function new(int 参数名);
    //     初始化语句
    // endfunction
    // int 参数名：声明一个整数参数，接收创建对象时传入的数字。
    // 构造函数不写 void 或其他返回类型。

    // TODO：在下面写构造函数。
    // 1. 接收一个整数参数，名字为 start_value。
    // 2. 在函数里面，把 start_value 赋给对象的 count。
    function new(int start_value);
    this.count = start_value;
    endfunction

endclass

module tb_constructor;
    initial begin
        counter_with_init counter_h;

        // new(10) 创建对象，并把 10 传给构造函数的参数。
        counter_h = new(10);

        // 预期打印 count=10：初始化由构造函数完成。
        $display("count=%0d", counter_h.count);
        $finish;
    end
endmodule
