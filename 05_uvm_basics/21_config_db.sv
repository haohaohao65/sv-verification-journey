// 练习 21：test 用 config_db 传递整数配置，driver 在 build_phase 读取。
// config = 配置，db = 数据库，extra = 额外加数。
// 本题只填写 set 和 get 两个调用。
`include "16_driver_class.sv"

class add_sequencer extends uvm_sequencer #(add_item);
    `uvm_component_utils(add_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass

class configured_driver extends add_driver;
    `uvm_component_utils(configured_driver)

    int extra = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        bit found;  // 保存查找是否成功：1 = 找到，0 = 没找到。
        super.build_phase(phase);

        // TODO 1：调用 uvm_config_db #(int)::get，把返回的成功标志保存到 found。
        // 四个参数：当前 driver 的 this、空字符串 ""、配置名 "extra"、变量 extra。
        // get 将配置值写入第四个参数；它的函数返回值表示是否找到配置。
        found = uvm_config_db #(int)::get(this,"","extra",extra);

        // !found 表示“没有找到配置”。fatal 表示致命错误，默认会结束仿真。
        if (!found) begin
            `uvm_fatal("MISSING_CONFIG", "Integer configuration extra was not found")
        end

        $display("driver: extra=%0d", extra);
    endfunction

    virtual task run_phase(uvm_phase phase);
        add_item req_h;
        forever begin
            seq_item_port.get_next_item(req_h);
            calculate(req_h);
            req_h.result = req_h.result + extra;
            seq_item_port.item_done();
        end
    endtask
endclass

class configured_sequence extends uvm_sequence #(add_item);
    `uvm_object_utils(configured_sequence)

    function new(string name = "configured_sequence");
        super.new(name);
    endfunction

    virtual task body();
        add_item req_h;
        req_h = add_item::type_id::create("req");
        start_item(req_h);
        req_h.a = 6;
        req_h.b = 8;
        finish_item(req_h);

        // 本例预期 6 + 8 + 3 = 17。
        if (req_h.result != 17) begin
            `uvm_error("ADD_CHECK", "Expected result 17 with extra configuration 3")
        end
        else begin
            $display("sequence: result=%0d", req_h.result);
        end
    endtask
endclass

class configured_env extends uvm_env;
    `uvm_component_utils(configured_env)

    configured_driver drv_h;
    add_sequencer sqr_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_h = configured_driver::type_id::create("drv", this);
        sqr_h = add_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv_h.seq_item_port.connect(sqr_h.seq_item_export);
    endfunction
endclass

class config_test extends uvm_test;
    `uvm_component_utils(config_test)

    configured_env env_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // TODO 2：调用 uvm_config_db #(int)::set，登记 extra = 3。
        // 四个参数：当前 test 的 this、相对路径 "env.drv"、配置名 "extra"、值 3。
        // 此时先登记配置，后创建环境。set 不需要目标 driver 已经存在。
        uvm_config_db #(int)::set(this,"env.drv","extra",3);
        
        env_h = configured_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        configured_sequence seq_h;
        phase.raise_objection(this);
        seq_h = configured_sequence::type_id::create("seq");
        seq_h.start(env_h.sqr_h);
        phase.drop_objection(this);
    endtask
endclass

module tb_config_db;
    initial begin
        run_test("config_test");
    end
endmodule
