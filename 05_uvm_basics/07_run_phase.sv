// 练习 7：run_phase（运行阶段）与 objection（异议）
// 沿用已经理解的测试类、构造函数和 build_phase。
// 本次观察：运行阶段开始 -> 等待 10 ns -> 运行工作完成。

// 时间配置：1 ns 是时间单位，1 ps 是时间精度。
// ns = nanosecond（纳秒），ps = picosecond（皮秒）。
`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class run_phase_test extends uvm_test;
    `uvm_component_utils(run_phase_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        $display("new");
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        $display("build_phase");
    endfunction

    // 新方法的声明形式：
    // virtual task run_phase(uvm_phase phase);
    //     运行阶段的语句
    // endtask
    // task（任务）可以包含 # 延时或 @ 等待；声明中不写 void。
    // virtual 与 uvm_phase phase 的含义沿用上一份练习。

    // objection（异议）：在这里表示“我反对当前运行阶段现在结束”。
    // phase.raise_objection(this)：提出异议，保留当前运行阶段。
    // phase.drop_objection(this)：撤回这次异议，允许阶段在所有异议清零后结束。
    // raise = 提出/增加，drop = 撤回/减少；this 标识当前测试对象。
    // 任务是否返回，与阶段是否结束是两件事；等待需要阶段持续才能走完。

    // TODO：在下面编写 run_phase 任务，依次完成这些操作：
    // 1. 提出异议。
    // 2. 打印 "run start"（运行开始）。
    // 3. 用 #10ns; 等待 10 纳秒。
    // 4. 打印 "run end"（运行工作完成）。
    // 5. 撤回异议。
    // 打印完成后再撤回，确保整个任务期间都受到这次异议的保护。
    virtual task run_phase(uvm_phase phase);
           phase.raise_objection(this);
           $display("run start");
           #10ns;
           $display("run end");
           phase.drop_objection(this);
    endtask

endclass

module tb_run_phase;
    initial begin
        run_test("run_phase_test");
    end
endmodule
