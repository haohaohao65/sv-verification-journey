// 练习 12：组件修改请求对象，test 读取同一个对象中的结果。
// shared = 共享的，calculate = 计算。
// 本次只填写两个 TODO，不创建第二个请求对象。

import uvm_pkg::*;
`include "uvm_macros.svh"

class add_request extends uvm_object;
    `uvm_object_utils(add_request)

    int a;
    int b;
    int result = 0;  // 这次把答案也保存在请求对象里。

    function new(string name = "add_request");
        super.new(name);
    endfunction
endclass

class calculator_component extends uvm_component;
    `uvm_component_utils(calculator_component)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // void：不通过函数返回值交回答案。
    // req 指向调用处传入的那个对象，可以读取和修改其中的变量。
    function void calculate(add_request req);
        // TODO 1：将 req.a 与 req.b 的和，保存到同一个对象的 result 中。
       req.result = req.a + req.b;
    endfunction
endclass

class shared_object_test extends uvm_test;
    `uvm_component_utils(shared_object_test)

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

        phase.raise_objection(this);

        req_h = add_request::type_id::create("req");
        req_h.a = 3;
        req_h.b = 4;

        $display("before: result=%0d", req_h.result);

        // TODO 2：通过 child_h 调用 calculate，传入 req_h。
        // calculate 没有返回值，直接调用即可。
        child_h.calculate(req_h);

        $display("after: result=%0d", req_h.result);
        phase.drop_objection(this);
    endtask
endclass

module tb_shared_object;
    initial begin
        run_test("shared_object_test");
    end
endmodule
