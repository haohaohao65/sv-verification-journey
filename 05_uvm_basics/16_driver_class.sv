// 练习 16：定义一个处理 add_item 的 UVM driver 类。
// driver = 驱动器。本题先练习类的继承与注册。
// calculate 沿用前面的加法功能；接收请求的通路会在后续练习中搭建。

import uvm_pkg::*;
`include "uvm_macros.svh"

class add_item extends uvm_sequence_item;
    `uvm_object_utils(add_item)

    int a;
    int b;
    int result = 0;

    function new(string name = "add_item");
        super.new(name);
    endfunction
endclass

// TODO 1：修改下一行，让 add_driver 继承 uvm_driver，指定请求类型为 add_item。
// 带类型参数的继承形式：class 类名 extends 基类名 #(请求类型);
class add_driver extends uvm_driver#(add_item);

    // TODO 2：使用组件注册宏，注册 add_driver。
    `uvm_component_utils(add_driver);

    // driver 是组件，构造函数接收名字和上级组件句柄。
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // 这段计算沿用之前学过的“通过句柄修改同一个对象”。
    // 它需要被调用才会执行；继承 uvm_driver 不会自动调用它。
    function void calculate(add_item item_h);
        item_h.result = item_h.a + item_h.b;
    endfunction
endclass
