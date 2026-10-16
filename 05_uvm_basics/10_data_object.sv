// 练习 10：用一个数据对象保存一次加法请求。
// request = 请求，object = 对象。
// 保留上一个练习的小计算器，只填写 run_phase 中的三个 TODO。

import uvm_pkg::*;
`include "uvm_macros.svh"

// 数据对象：保存要相加的两个数，不加入 UVM 组件层次。
class add_request extends uvm_object;
    `uvm_object_utils(add_request)

    int a;
    int b;

    // 不传 name 时，默认使用 "add_request"。
    // uvm_object 的构造函数只接收名字，没有组件的 parent 参数。
    function new(string name = "add_request");
        super.new(name);
    endfunction
endclass

// 计算器组件：沿用练习 9 中的加法功能。
class calculator_component extends uvm_component;
    `uvm_component_utils(calculator_component)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function int add(int a, int b);
        return a + b;
    endfunction
endclass

class data_object_test extends uvm_test;
    `uvm_component_utils(data_object_test)

    calculator_component child_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        child_h = calculator_component::type_id::create("child", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        add_request req_h;
        int result;

        phase.raise_objection(this);

        // TODO 1：通过工厂创建 add_request 对象，名字为 "req"，保存到 req_h。
        // 数据对象的创建形式：句柄 = 类名::type_id::create("对象名字");
        req_h = add_request::type_id::create("req");
        // TODO 2：把 req_h 指向的对象中的 a 设为 3，b 设为 4。
        req_h.a = 3;
        req_h.b = 4;
        // TODO 3：调用 child_h.add，把 req_h.a、req_h.b 作为参数。
        // 将返回值保存到 result。
        result = child_h.add(req_h.a,req_h.b);
        $display("result=%0d", result);
        phase.drop_objection(this);
    endtask
endclass

module tb_data_object;
    initial begin
        run_test("data_object_test");
    end
endmodule
