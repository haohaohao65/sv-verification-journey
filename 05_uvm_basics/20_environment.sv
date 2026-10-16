// 练习 20：用 env 管理 driver 和 sequencer。
// env 是 environment（环境）的简写。只填写三个 TODO。
`include "16_driver_class.sv"

class add_sequencer extends uvm_sequencer #(add_item);
    `uvm_component_utils(add_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

// 沿用持续接收请求的 driver。
class environment_driver extends add_driver;
    `uvm_component_utils(environment_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        add_item req_h;
        forever begin
            seq_item_port.get_next_item(req_h);
            calculate(req_h);
            seq_item_port.item_done();
        end
    endtask
endclass

class add_sequence extends uvm_sequence #(add_item);
    `uvm_object_utils(add_sequence)

    function new(string name = "add_sequence");
        super.new(name);
    endfunction

    virtual task body();
        add_item req_h;
        req_h = add_item::type_id::create("req");
        start_item(req_h);
        req_h.a = 6;
        req_h.b = 8;
        finish_item(req_h);
        if (req_h.result != 14) begin
            `uvm_error("ADD_CHECK", "Expected result 14")
        end
        else begin
            $display("sequence: result=%0d", req_h.result);
        end
    endtask
endclass

// 环境也是组件：由它创建、连接属于这个环境的子组件。
class add_env extends uvm_env;
    `uvm_component_utils(add_env)

    environment_driver drv_h;
    add_sequencer sqr_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // TODO 1：创建 environment_driver，名字为 "drv"，保存到 drv_h。
        // 上级组件设为 this；在这个方法中 this 表示当前 add_env 对象。
        drv_h = environment_driver::type_id::create("drv",this);

        // TODO 2：创建 add_sequencer，名字为 "sqr"，保存到 sqr_h。
        // 上级组件同样是当前环境对象 this。
        sqr_h = add_sequencer::type_id::create("sqr",this);

        $display("driver path=%s", drv_h.get_full_name());
        $display("sequencer path=%s", sqr_h.get_full_name());
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv_h.seq_item_port.connect(sqr_h.seq_item_export);
    endfunction
endclass

class environment_test extends uvm_test;
    `uvm_component_utils(environment_test)

    add_env env_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env_h = add_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        add_sequence seq_h;
        phase.raise_objection(this);

        seq_h = add_sequence::type_id::create("seq");

        // TODO 3：启动 seq_h，使用 env_h 里面的 sqr_h 作为调度器。
        // env_h.sqr_h：先找到环境对象，再取它保存的调度器句柄。
        seq_h.start(env_h.sqr_h);
        
        $display("test: sequence finished");
        phase.drop_objection(this);
    endtask
endclass

module tb_environment;
    initial begin
        run_test("environment_test");
    end
endmodule
