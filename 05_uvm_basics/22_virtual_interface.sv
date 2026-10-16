// 练习 22：类通过 virtual interface 引用已有接口实例，并修改其中的信号。
// interface = 接口，virtual = 虚拟的，enable = 启用。
// 本次用普通 SV 小例子单独学习接口引用，只填两个 TODO。

interface demo_if;
    logic enable;
endinterface

// writer = 写入者。这是一个用来写接口信号的普通类。
class signal_writer;
    // TODO 1：声明一个 virtual interface，接口类型是 demo_if，句柄名为 vif。
    virtual interface demo_if vif;
    // 参数 interface_h 是调用处传入的接口引用。
    // 构造函数保存引用，不创建新的接口实例。
    function new(virtual interface demo_if interface_h);
        vif = interface_h;
    endfunction

    function void set_enable();
        // TODO 2：通过 vif，把引用的接口实例中的 enable 信号设为 1。
        vif.enable = 1;
    endfunction
endclass

module tb_virtual_interface;
    // 这里实例化 demo_if，实例名字是 bus_if。
    // 空括号表示本例的接口实例没有需要连接的端口。
    demo_if bus_if();
    signal_writer writer_h;

    initial begin
        bus_if.enable = 0;
        $display("before: enable=%0d", bus_if.enable);

        // new 创建 signal_writer 对象，把已有的 bus_if 交给构造函数。
        writer_h = new(bus_if);
        writer_h.set_enable();

        // 从 module 直接读取接口信号，观察类中写入的结果。
        $display("after: enable=%0d", bus_if.enable);
        $finish;
    end
endmodule
