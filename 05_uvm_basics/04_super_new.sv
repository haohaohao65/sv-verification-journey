// 练习 4：子类怎样调用父类的构造函数
// init = 初始化，step = 步长。
// this 表示当前对象；super 用于访问当前对象中继承自父类的部分。
// super.new(...) 调用父类的构造函数，不会另外创建一个父类对象。
// 这一步把已经学过的“继承”和“构造函数”连接起来。

class init_counter;
    int count;

    function new(int start_value);
        count = start_value;
    endfunction
endclass

class step_counter extends init_counter;
    int step;

    // TODO：编写子类构造函数。
    // 1. 接收两个整数参数，依次叫 start_value、step_value。
    //    多个参数用逗号分隔，例如：int 参数一, int 参数二。
    // 2. 第一条语句用 super.new(...) 把 start_value 交给父类初始化 count。
    // 3. 再把 step_value 赋给子类成员 step。
    //    可以写 this.成员名，也可以在无同名参数遮蔽时直接使用成员名。
    function new(int start_value,int step_value);
    super.new(start_value);
    this.step=step_value;
    endfunction

endclass

module tb_super_new;
    initial begin
        step_counter counter_h;

        // 10 对应第一个参数，2 对应第二个参数。
        counter_h = new(10, 2);

        // 预期 count=10 step=2；两项初始化都作用于同一个对象。
        $display("count=%0d step=%0d", counter_h.count, counter_h.step);
        $finish;
    end
endmodule
