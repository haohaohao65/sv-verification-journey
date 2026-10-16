// 练习 15：创建 sequencer，并在启动 sequence 时指定它。
// sequencer = 请求调度器；sqr 是本例中给它起的简写名字。
// 本次只填写两个 TODO。body 仍只准备请求，尚未提交 item。

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

// sequencer 是组件；#(add_item) 指定它处理的请求类型。
class add_sequencer extends uvm_sequencer #(add_item);
    `uvm_component_utils(add_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

class prepare_sequence extends uvm_sequence #(add_item);
    `uvm_object_utils(prepare_sequence)

    function new(string name = "prepare_sequence");
        super.new(name);
    endfunction

    virtual task body();
        add_item req_h;

        req_h = add_item::type_id::create("req");
        req_h.a = 6;
        req_h.b = 8;
        $display("sequence body: a=%0d b=%0d", req_h.a, req_h.b);
    endtask
endclass

class sequencer_test extends uvm_test;
    `uvm_component_utils(sequencer_test)

    add_sequencer sqr_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // TODO 1：通过工厂创建 add_sequencer，保存到 sqr_h。
        // 组件名字为 "sqr"，上级组件是当前 test 对象 this。
        sqr_h = add_sequencer::type_id::create("sqr",this);

        $display("sequencer path=%s", sqr_h.get_full_name());
    endfunction

    virtual task run_phase(uvm_phase phase);
        prepare_sequence seq_h;

        phase.raise_objection(this);

        seq_h = prepare_sequence::type_id::create("seq");
        $display("test: before start");

        // TODO 2：通过 seq_h 调用 start，这次传入 sqr_h。
        // 这会为 sequence 指定调度器；不会自动提交 body 中创建的 item。
        seq_h.start(sqr_h);

        $display("test: after start");
        phase.drop_objection(this);
    endtask
endclass

module tb_sequencer;
    initial begin
        run_test("sequencer_test");
    end
endmodule
