// 练习 18：完成一次请求的提交、接收与完成确认。
// handshake = 握手。本题只填写四个交接动作。
`include "16_driver_class.sv"

class add_sequencer extends uvm_sequencer #(add_item);
    `uvm_component_utils(add_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

class one_item_sequence extends uvm_sequence #(add_item);
    `uvm_object_utils(one_item_sequence)

    function new(string name = "one_item_sequence");
        super.new(name);
    endfunction

    virtual task body();
        add_item req_h;
        req_h = add_item::type_id::create("req");

        // TODO 1：调用 start_item，传入 req_h，申请提交这条请求的许可。
        start_item(req_h);

        // start_item 返回后填写数据；这两次赋值不消耗仿真时间。
        req_h.a = 6;
        req_h.b = 8;
        $display("sequence: request a=%0d b=%0d", req_h.a, req_h.b);

        // TODO 2：调用 finish_item，传入 req_h，提交请求并等待完成确认。
        // start_item 与 finish_item 之间不要加入 # 延时或 @ 等待。
        finish_item(req_h);

        // 本例由 driver 修改同一个请求对象的 result，沿用练习 12 的方式。
        if (req_h.result != 14) begin
            `uvm_error("ADD_CHECK", "Expected result 14 after request completion")
        end
        else begin
            $display("sequence: completed result=%0d", req_h.result);
        end
    endtask
endclass

// 继承你写好的 add_driver，也就继承了 calculate 方法和请求端口。
class one_item_driver extends add_driver;
    `uvm_component_utils(one_item_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        add_item req_h;

        // TODO 3：通过 seq_item_port 调用 get_next_item，参数为 req_h。
        // 等待取得请求，把取得的对象句柄写入 req_h；这里不用 new。
        seq_item_port.get_next_item(req_h);

        calculate(req_h);
        $display("driver: result=%0d", req_h.result);
        
        seq_item_port.item_done();
        // TODO 4：通过 seq_item_port 调用 item_done，括号中不传参数。
        // 告知 sequencer 这条请求已处理完成，让 sequence 可以继续。

    endtask
endclass

class item_handshake_test extends uvm_test;
    `uvm_component_utils(item_handshake_test)

    one_item_driver drv_h;
    add_sequencer sqr_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_h = one_item_driver::type_id::create("drv", this);
        sqr_h = add_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv_h.seq_item_port.connect(sqr_h.seq_item_export);
    endfunction

    virtual task run_phase(uvm_phase phase);
        one_item_sequence seq_h;
        phase.raise_objection(this);

        seq_h = one_item_sequence::type_id::create("seq");
        seq_h.start(sqr_h);
        $display("test: sequence finished");

        phase.drop_objection(this);
    endtask
endclass

module tb_item_handshake;
    initial begin
        run_test("item_handshake_test");
    end
endmodule
