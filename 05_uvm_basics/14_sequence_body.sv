// 练习 14：启动 sequence，在 body 中准备一个请求。
// body = 主体，start = 开始。
// 本例只准备并打印请求，尚未发送请求或执行加法。

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

// #(add_item)：将这个 sequence 的请求类型指定为 add_item。
// 这里的 # 是类的参数写法，不是时间延迟，也不会创建 item 对象。
class prepare_sequence extends uvm_sequence #(add_item);
    `uvm_object_utils(prepare_sequence)

    function new(string name = "prepare_sequence");
        super.new(name);
    endfunction

    // start 会安排执行 body；body 不是组件的 run_phase。
    // virtual 和 task 的含义与之前相同。
    virtual task body();
        add_item req_h;

        // TODO 1：通过工厂创建 add_item，名字为 "req"，保存到 req_h。
        req_h  = add_item::type_id::create("req");

        // TODO 2：把请求中的 a 设为 6，b 设为 8。
        req_h.a = 6;
        req_h.b = 8;

        $display("sequence body: a=%0d b=%0d", req_h.a, req_h.b);
    endtask
endclass

class sequence_body_test extends uvm_test;
    `uvm_component_utils(sequence_body_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        prepare_sequence seq_h;

        phase.raise_objection(this);

        // sequence 也是对象：工厂创建后，只是对象存在，还没有运行 body。
        seq_h = prepare_sequence::type_id::create("seq");
        $display("test: before start");

        // TODO 3：通过 seq_h 调用 start，参数填 null。
        // 本例不发送 item，所以不需要用于传递请求的 sequencer。
        // null 表示不提供该组件句柄；它不是字符串，不加引号。
        // start 完成后，才继续执行下一行。
        seq_h.start(null);

        $display("test: after start");
        phase.drop_objection(this);
    endtask
endclass

module tb_sequence_body;
    initial begin
        run_test("sequence_body_test");
    end
endmodule
