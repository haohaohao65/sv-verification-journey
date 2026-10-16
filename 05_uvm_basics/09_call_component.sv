// 练习 9：通过句柄调用子组件的方法。
// calculator = 计算器，add = 相加，result = 结果。
// 本次只填写两个 TODO，不需要增加延时。

import uvm_pkg::*;
`include "uvm_macros.svh"

class calculator_component extends uvm_component;
    `uvm_component_utils(calculator_component)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // int：这个函数返回一个整数；a、b：调用时传入的两个整数。
    // return 表达式; 会将表达式的值交回调用处，并结束函数。
    function int add(int a, int b);
        // TODO 1：返回 a 与 b 的和。
    return a+b;
    endfunction
endclass

class call_component_test extends uvm_test;
    `uvm_component_utils(call_component_test)

    calculator_component child_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        child_h = calculator_component::type_id::create("child", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        int result;

        phase.raise_objection(this);

        // 调用形式：句柄.方法名(参数);
        // 如果方法返回一个值，可以写：变量 = 句柄.方法名(参数);
        // TODO 2：通过 child_h 调用 add，传入 3、4，把返回值保存到 result。
        result = child_h.add(3,4);
        $display("result=%0d", result);
        phase.drop_objection(this);
    endtask
endclass

module tb_call_component;
    initial begin
        run_test("call_component_test");
    end
endmodule
