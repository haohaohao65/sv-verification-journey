// 练习 8：在 build_phase 中创建一个子组件
// demo = 示例，component = 组件，hierarchy = 层次，child = 子级。
// 本次只观察组件创建与归属关系，运行过程不包含延时。

import uvm_pkg::*;
`include "uvm_macros.svh"

// 示例组件：继承 UVM 的组件基类。
class demo_component extends uvm_component;
    `uvm_component_utils(demo_component)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // get_full_name() 取得对象在 UVM 组件层次中的完整名字。
        $display("child path=%s", get_full_name());
    endfunction
endclass

class hierarchy_test extends uvm_test;
    `uvm_component_utils(hierarchy_test)

    // TODO 1：在类中声明 demo_component 类型的句柄 child_h。
    // 声明在类中，它就是这个测试对象的成员，方法中可以使用它。
    demo_component child_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // 工厂创建的形式：
        // 句柄 = 类名::type_id::create("对象名字", 上级组件句柄);
        // type_id 是注册宏提供的类型别名，对应这个类的工厂创建工具。
        // :: 在指定的类或类型中查找名字；create = 创建。
        // create 最终调用构造函数，返回新对象的句柄。
        // this 引用当前测试对象：传它作为 parent，子组件归属于当前测试。

        // TODO 2：通过工厂创建 demo_component，将返回句柄保存到 child_h。
        // 新对象的名字设为 "child"，上级组件设为 this。
        child_h = demo_component::type_id::create("child",this);

    endfunction
endclass

module tb_hierarchy;
    initial begin
        run_test("hierarchy_test");
    end
endmodule
