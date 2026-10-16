// 练习 19：让同一个 driver 持续接收请求。
// continuous = 持续的，forever = 永远。
// 本题只给 driver 的一次处理过程加上循环边界。
`timescale 1ns/1ps
`include "16_driver_class.sv"

class add_sequencer extends uvm_sequencer #(add_item);
    `uvm_component_utils(add_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

class two_item_sequence extends uvm_sequence #(add_item);
    `uvm_object_utils(two_item_sequence)

    function new(string name = "two_item_sequence");
        super.new(name);
    endfunction

    virtual task body();
        add_item req_h;

        // 第一条请求：6 + 8，预期结果 14。
        req_h = add_item::type_id::create("first");
        start_item(req_h);
        req_h.a = 6;
        req_h.b = 8;
        finish_item(req_h);
        if (req_h.result != 14) begin
            `uvm_error("FIRST_CHECK", "Expected first result 14")
        end
        else begin
            $display("sequence: first result=%0d", req_h.result);
        end

        // 延时放在第一条请求完成之后、第二条请求申请之前。
        // 它不在任何一对 start_item / finish_item 中间。
        $display("sequence: waiting 5ns before second request");
        #5ns;

        // 第二条请求：2 + 5，预期结果 7。
        req_h = add_item::type_id::create("second");
        start_item(req_h);
        req_h.a = 2;
        req_h.b = 5;
        finish_item(req_h);
        if (req_h.result != 7) begin
            `uvm_error("SECOND_CHECK", "Expected second result 7")
        end
        else begin
            $display("sequence: second result=%0d", req_h.result);
        end
    endtask
endclass

class continuous_driver extends add_driver;
    `uvm_component_utils(continuous_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        add_item req_h;

        // TODO 1：在这里开始一个 forever 循环，用 begin 包住多条语句。
        forever begin
            $display("driver: waiting for request");
            seq_item_port.get_next_item(req_h);
            calculate(req_h);
            $display("driver: result=%0d", req_h.result);
            seq_item_port.item_done();
    
        // TODO 2：在这里结束这个循环的 begin/end 语句块。
        end
    endtask
endclass

class continuous_driver_test extends uvm_test;
    `uvm_component_utils(continuous_driver_test)

    continuous_driver drv_h;
    add_sequencer sqr_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_h = continuous_driver::type_id::create("drv", this);
        sqr_h = add_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv_h.seq_item_port.connect(sqr_h.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);
        two_item_sequence seq_h;
        phase.raise_objection(this);

        seq_h = two_item_sequence::type_id::create("seq");
        seq_h.start(sqr_h);
        $display("test: both requests completed");

        phase.drop_objection(this);
    endtask
endclass

module tb_continuous_driver;
    initial begin
        run_test("continuous_driver_test");
    end
endmodule
