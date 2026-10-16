// 练习 5：第一个独立 UVM test（测试）
// 目标：让 UVM 创建 hello_test，在构造函数里打印一句话。
// 沿用已学过的 extends（继承）、function new（构造函数）、super.new。

// package（包）把相关定义放在一起；uvm_pkg 是 UVM 提供的包。
// import（导入）让这里能使用包里的名字；::* 表示导入该包的所有可见名称。
import uvm_pkg::*;

// `include 带入文件内容。uvm_macros.svh 提供 UVM 的宏。
// macro（宏）是编译前会展开成代码的文本工具，调用时名字前面有反引号 `。
`include "uvm_macros.svh"

class hello_test extends uvm_test;
    // 把 hello_test 注册到 UVM factory（工厂）。
    // 工厂负责按登记的类名创建对象；这次先使用基本注册功能。
    `uvm_component_utils(hello_test)

    // TODO：在下面写构造函数。
    // 1. 接收两个参数，依次为 string name、uvm_component parent。
    //    string 是字符串类型，name 是这个对象的名字。
    //    uvm_component 是 UVM 的组件基类；parent 是上级组件的句柄。
    //    这里的上级表示组件的包含关系，不是 extends 所描述的类继承关系。
    // 2. 第一条语句调用 super.new(...)，把 name、parent 传给父类。
    // 3. 用 $display 打印 "hello UVM"。
    function new(string name,uvm_component parent);
    super.new(name,parent);
    $display("hello UVM");
    endfunction

endclass

module tb_uvm_hello;
    // run_test 是 UVM 提供的任务：按名字创建测试，并启动 UVM 的执行流程。
    // 这次创建对象由 UVM 完成；我们通过填写构造函数观察创建动作。
    initial begin
        run_test("hello_test");
    end
endmodule
