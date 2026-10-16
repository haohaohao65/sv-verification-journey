// 练习 17：在 connect_phase 中连接 driver 与 sequencer。
// connect = 连接，phase = 阶段。只填写一个 TODO。

// 沿用练习 16 中你写好的 add_item、add_driver 定义。
`include "16_driver_class.sv"

class add_sequencer extends uvm_sequencer #(add_item);
    `uvm_component_utils(add_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

class connection_test extends uvm_test;
    `uvm_component_utils(connection_test)

    add_driver drv_h;
    add_sequencer sqr_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // 构建阶段：先创建两个组件。
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_h = add_driver::type_id::create("drv", this);
        sqr_h = add_sequencer::type_id::create("sqr", this);
    endfunction

    // 连接阶段：UVM 在构建阶段结束后自动调用。
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // drv_h.seq_item_port：driver 继承来的请求访问端口。
        // sqr_h.seq_item_export：sequencer 提供的请求接口。
        // connect 是端口的连接方法：使用方端口.connect(提供方接口);
        // TODO：把 driver 的 seq_item_port 连接到 sequencer 的 seq_item_export。
        drv_h.seq_item_port.connect(sqr_h.seq_item_export);

    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        // size() 取得这个端口连接到的请求接口数量，本例应为 1。
        // 此时 UVM 已完成连接关系的整理，可以读取连接数量。
        $display("request interface count=%0d", drv_h.seq_item_port.size());

        phase.drop_objection(this);
    endtask
endclass

module tb_connect_phase;
    initial begin
        run_test("connection_test");
    end
endmodule
