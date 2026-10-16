// 练习 1：类的继承
// base = 基础，counter = 计数器，count = 计数值，step = 步长。
// 本练习先学习 SystemVerilog 类语法，为后续最小 UVM 示例做准备。

// 已讲解的父类：类是创建对象的图纸，这里还没有创建对象。
class base_counter;
    int count = 0;
endclass

// 请在下面写你的子类：
// 1. 子类名为 my_counter。
// 2. 用 extends 继承 base_counter。extends 表示“扩展/继承”。
// 3. 新增整数成员 step，初始值为 1。
// 4. count 从父类继承，直接沿用，不需要重新声明。
// 当前只写类定义；创建对象与运行示例留到下一步。

class my_counter extends base_counter;
int step = 1;
endclass