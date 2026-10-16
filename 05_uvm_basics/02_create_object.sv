// 练习 2：创建对象，使用继承的成员
// 先在 01_class_inheritance.sv 中完成 my_counter，再填写本文件。

// `include 把指定文件的内容带入此处，沿用上一份练习的类定义。
`include "01_class_inheritance.sv"

// module 是仿真顶层；initial 中的语句在仿真开始时执行一次。
module tb_counter;
    initial begin
        // 类是图纸；对象是根据图纸创建的一份实例。
        // handle（句柄）用于引用对象。
        // 声明句柄的形式：类型名 句柄名;
        // 仅声明句柄还没有创建对象，new() 才创建对象并返回句柄。
        // 创建的形式：句柄名 = new();
        // 访问成员的形式：句柄名.成员名

        // TODO 1：声明 my_counter 类型的句柄，名字为 counter_h。
        // TODO 2：用 new() 创建对象，将返回的句柄赋给 counter_h。
        // TODO 3：把对象的 count 设为 5，把 step 设为 2。
        // 请把你的语句写在下面，并保留“先声明、再创建、再访问”的顺序。
        my_counter counter_h;
        counter_h = new();
        counter_h.count = 5;
        counter_h.step = 2;

        // $display 打印信息；%0d 用十进制显示后面的整数。
        // count 来自父类，step 来自子类；它们都属于这个对象。
        $display("count=%0d step=%0d", counter_h.count, counter_h.step);

        // $finish 结束仿真。
        $finish;
    end
endmodule
