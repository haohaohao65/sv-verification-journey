// 共享 UART 接口：集中声明 TX/RX 信号、时钟块和各角色可见的端口方向。
// s_axis 是 TX 的并行输入，m_axis 是 RX 的并行输出；s/m 不是测试名称。
interface uart_if #(DATA_WIDTH = 8)(input logic clk);

    // DUT 使用高有效同步复位，必须在时钟上升沿采到 rst=1 才执行复位。
    logic rst;

    // TX AXI
    logic [DATA_WIDTH - 1:0] s_axis_tdata;
    logic s_axis_tvalid;
    logic s_axis_tready;

    // TX UART
    logic txd;
    logic tx_busy;

    // RX UART
    logic rxd;
    logic rx_busy;
    logic rx_overrun_error;
    logic rx_frame_error;

    // RX AXI
    logic [DATA_WIDTH - 1:0] m_axis_tdata;
    logic m_axis_tvalid;
    logic m_axis_tready;

    // 波特率分频配置：当前 TX 的起始/数据位名义位周期为 prescale*8 个时钟。
    logic [15:0] prescale;

    // 方向从 DUT 的角度定义；modport 是接口视图，不会产生新的信号或接口实例。
    modport dut_if(
        input  clk,
        input  rst,

        input  s_axis_tdata,
        input  s_axis_tvalid,
        output s_axis_tready,

        output txd,
        output tx_busy,

        input  rxd,

        output m_axis_tdata,
        output m_axis_tvalid,
        input  m_axis_tready,

        output rx_busy,
        output rx_overrun_error,
        output rx_frame_error,

        input prescale
    );

    // Driver 在此时钟块读写接口；input/output 方向从验证组件的角度定义。
    // input #1step 在时钟事件前一个仿真精度步采样；output #0 以零偏移调度驱动。
    // 这样 Monitor 看到的是沿前稳定值，而不是同一沿 NBA 更新后的寄存器值。
    clocking dri_cb @(posedge clk);
        default input #1step output #0;

        output rst;

        output s_axis_tdata;
        output s_axis_tvalid;
        input  s_axis_tready;

        output prescale;

        input txd;
        input tx_busy;

        output rxd;

        input m_axis_tdata;
        input m_axis_tvalid;
        output m_axis_tready;

        input rx_busy;
        input rx_overrun_error;
        input rx_frame_error;
    endclocking

    // AXI 监测视图：只读并行握手和数据；@(该时钟块) 与 clk 上升沿关联。
    clocking tx_axi_mon_cb @(posedge clk);
        default input #1step;

        input rst;
        input s_axis_tdata;
        input s_axis_tvalid;
        input s_axis_tready;
        input tx_busy;  // 当前 axi_monitor 也读取它
    endclocking

    // UART 监测视图：只读串行输出、发送状态、复位和配置。
    clocking tx_uart_mon_cb @(posedge clk);
        default input #1step;

        input rst;
        input txd;
        input tx_busy;
        input prescale;
    endclocking

    // 一个 Monitor modport 可以提供两个 clocking block，供两类 Monitor 分别使用。
    // virtual uart_if.tx_mon_if 用于声明句柄类型；句柄.tx_uart_mon_cb 用于访问时钟块。
    modport dri_if(clocking dri_cb);
    modport tx_mon_if(clocking tx_axi_mon_cb, clocking tx_uart_mon_cb);


//SVA
    property continuous_datastable;
    @(posedge clk)
    disable iff(rst)
    s_axis_tvalid && !s_axis_tready |=> ($stable(s_axis_tdata) && s_axis_tvalid);
    endproperty

a_continuous_datastable:      //给断言命名，方便从日志定位
    assert property(continuous_datastable);
    else $fatal(1, "AXI data/valid changed while waiting");      //$fatal触发终止测试

endinterface
