// 练习 13：用 uvm_sequence_item 表示一次请求，并自动检查结果。
// item = 条目，sequence = 序列（一串有安排的请求），check = 检查。
// 这里只学习 item，还没有使用 sequence 的发送机制。
// 只填两个 TODO，保留计算器已有的处理方式。

import uvm_pkg::*;
`include "uvm_macros.svh"

// 一次加法请求：仍是数据对象，不是组件。
class add_item extends uvm_sequence_item;
    `uvm_object_utils(add_item)

    int a;
    int b;
    int result = 0;

    function new(string name = "add_item");
        super.new(name);
    endfunction
endclass

class calculator_component extends uvm_component;
    `uvm_component_utils(calculator_component)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void calculate(add_item req);
        req.result = req.a + req.b;
    endfunction
endclass

class item_test extends uvm_test;
    `uvm_component_utils(item_test)

    calculator_component child_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        child_h = calculator_component::type_id::create("child", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        add_item req_h;

        phase.raise_objection(this);

        // TODO 1：通过工厂创建 add_item，名字为 "req"，保存到 req_h。
        req_h = add_item::type_id::create("req",this);

        req_h.a = 6;
        req_h.b = 8;
        child_h.calculate(req_h);

        // TODO 2：填入“请求对象里的实际结果不等于 14”的条件。
        // != 表示“不等于”；if 条件成立就进入下面的错误分支。
        if ( req_h.result != 14 ) begin
            // uvm_error：记录一条 UVM 错误；参数为错误标识和说明文字。
            // 默认会继续执行，最终 UVM 汇总中会增加错误计数。
            `uvm_error("ADD_CHECK", "Addition result does not match expected value 14")
        end
        else begin
            $display("PASS: result=%0d", req_h.result);
        end

        phase.drop_objection(this);
    endtask
endclass

module tb_sequence_item;
    initial begin
        run_test("item_test");
    end
endmodule
