// 练习 23：通过 config_db 把接口引用传给 UVM 组件。
// 本题只填写 get 和 set 两个调用。
import uvm_pkg::*;
`include "uvm_macros.svh"

interface demo_if;
    logic enable;
endinterface

class interface_writer extends uvm_component;
    `uvm_component_utils(interface_writer)

    virtual interface demo_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        bit found;
        super.build_phase(phase);

        // TODO 1：从 config_db 读取接口引用，将成功标志保存到 found。
        // 配置类型是 virtual interface demo_if。
        // get 的四个参数：this、""、"vif"、变量 vif。
        found = uvm_config_db #(virtual interface demo_if)::get(this,"","vif",vif);

        if (!found) begin
            `uvm_fatal("MISSING_VIF", "Virtual interface configuration vif was not found")
        end
    endfunction

    function void set_enable();
        vif.enable = 1;
        $display("writer: enable=%0d", vif.enable);
    endfunction
endclass

class interface_config_test extends uvm_test;
    `uvm_component_utils(interface_config_test)

    interface_writer writer_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        writer_h = interface_writer::type_id::create("writer", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        writer_h.set_enable();
        phase.drop_objection(this);
    endtask
endclass

module tb_config_virtual_interface;
    demo_if bus_if();

    initial begin
        bus_if.enable = 0;
        $display("module: before enable=%0d", bus_if.enable);

        // TODO 2：通过 config_db 登记 bus_if 的接口引用。
        // 配置类型是 virtual interface demo_if。
        // set 的四个参数：null、"uvm_test_top.writer"、"vif"、接口实例 bus_if。
        // null 让 config_db 使用 UVM 根作为路径起点，因此这里填完整组件路径。
        uvm_config_db #(virtual interface demo_if)::set(null,"uvm_test_top.writer","vif",bus_if);

        // 先登记引用，再启动 UVM；组件随后在 build_phase 中读取。
        run_test("interface_config_test");
    end
endmodule
