// 练习 11：把请求对象的句柄传给计算器。
// argument = 参数。本次只填写两个 TODO。

import uvm_pkg::*;
`include "uvm_macros.svh"

class add_request extends uvm_object;
    `uvm_object_utils(add_request)

    int a;
    int b;

    function new(string name = "add_request");
        super.new(name);
    endfunction
endclass

class calculator_component extends uvm_component;
    `uvm_component_utils(calculator_component)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // 返回值仍是整数；参数改成 add_request 类型的句柄 req。
    // 调用时复制句柄，不复制对象，也不会自动创建新对象。
    // 函数内通过 req.a、req.b 读取同一个请求对象中的数据。
    function int add(add_request req);
        // TODO 1：返回请求对象中 a 与 b 的和。
    return req.a + req.b; 
    endfunction
endclass

class object_argument_test extends uvm_test;
    `uvm_component_utils(object_argument_test)

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

        req_h = add_request::type_id::create("req");
        req_h.a = 3;
        req_h.b = 4;

        // TODO 2：通过 child_h 调用 add，只传入请求对象的句柄 req_h。
        // 将返回值保存到 result。
        result = child_h.add(req_h);
        
        $display("result=%0d", result);
        phase.drop_objection(this);
    endtask
endclass

module tb_object_argument;
    initial begin
        run_test("object_argument_test");
    end
endmodule
