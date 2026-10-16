// 练习 6：观察构造函数之后的 build_phase（构建阶段）
// phase = 阶段；build = 构建。
// new 在创建对象时执行；build_phase 是创建后由 UVM 调用的方法。

import uvm_pkg::*;
`include "uvm_macros.svh"

class build_test extends uvm_test;
    `uvm_component_utils(build_test)

    // 沿用上一份练习已经学过的构造函数。
    function new(string name, uvm_component parent);
        super.new(name, parent);
        $display("new");
    endfunction

    // 本次的新方法形式：
    // virtual function void build_phase(uvm_phase phase);
    //     构建阶段的语句
    // endfunction
    // virtual：虚方法，让通过父类句柄的调用也能执行子类重新实现的版本。
    // void：该函数不返回数值或对象，只执行操作。
    // uvm_phase：UVM 提供的阶段类；phase 是 UVM 传来的阶段对象句柄。
    // 函数不能使用 # 延时或 @ 等待；本次只观察打印。

    // TODO：在下面编写 build_phase 方法。
    // 1. 使用上面给出的方法声明形式。
    // 2. 第一条语句调用 super.build_phase(phase)，执行父类的基础构建处理。
    // 3. 用 $display 打印 "build_phase"。
    // 这个方法由 UVM 自动调用，沿用下方 run_test 作为启动入口。
    virtual function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         $display("build_phase");
    endfunction

endclass

module tb_build_phase;
    initial begin
        run_test("build_test");
    end
endmodule
