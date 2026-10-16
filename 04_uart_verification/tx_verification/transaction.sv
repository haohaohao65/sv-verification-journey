// Transaction：组件之间传递的一笔记录；既保存输入激励，也保存监测结果。
// DATA_WIDTH 是数据位数，本项目目前使用默认的 8 位。
class transaction #(parameter DATA_WIDTH = 8);

    // rand 字段由 randomize() 求解；非 rand 字段由测试配置或 Monitor 赋值。
    rand logic rst;
    rand logic [DATA_WIDTH - 1:0] s_axis_tdata;
    rand logic s_axis_tvalid;
    logic s_axis_tready;
    logic txd;
    logic busy;
    rand logic [15:0] prescale;
    // UART Monitor 从串行帧中解码出的数据，不是 Generator 生成的输入数据。
    logic [DATA_WIDTH - 1:0] observed_data;

    int unsigned reset_after_cycles = 0;  //握手发生后reset_after_cycles个时钟插入复位
    bit aborted = 0;  //正在发送的帧被取消标志

    // 打印记录以便调试。尚未填写的监测字段可能显示 x，并不自动代表 DUT 出错。
    function void display(string name);
        $display("%s:rst=%0d,s_axis_tdata=%0d,s_axis_tvalid=%0d,s_axis_tready=%0d,txd=%0d,busy=%0d,prescale=%0d",
            name,
            this.rst,
            this.s_axis_tdata,
            this.s_axis_tvalid,
            this.s_axis_tready,
            this.txd,
            this.busy,
            this.prescale
        );
    endfunction

    // dist 设置随机选择的相对权重；定向测试中的 with 约束会进一步限定 rst。
    constraint rst_c {
        rst dist {
            0 := 98,
            1 := 2
        };
    }

    // soft 是可被其他约束覆盖的默认偏好，因此可以定向选择 prescale=1/4/8。
    constraint prescale_c {
        soft prescale == 4;
    }

    // 复位时不请求发送；本类的默认约束要求非复位记录发出有效请求。
    constraint valid_c {
        if (rst)
            s_axis_tvalid == 0;
        else
            s_axis_tvalid == 1;
    }

    // new() 后逐字段复制，产生独立对象；仅复制句柄会共享同一个对象。
    // 当前内部 t 使用 transaction 的默认参数，此实现按当前 DATA_WIDTH=8 使用。
    function transaction #(DATA_WIDTH) copy();
        transaction t;
        t                    = new();
        t.rst                = this.rst;
        t.s_axis_tdata       = this.s_axis_tdata;
        t.s_axis_tvalid      = this.s_axis_tvalid;
        t.s_axis_tready      = this.s_axis_tready;
        t.txd                = this.txd;
        t.busy               = this.busy;
        t.prescale           = this.prescale;
        t.observed_data      = this.observed_data;
        t.reset_after_cycles = this.reset_after_cycles;
        t.aborted            = this.aborted;
        return t;
    endfunction

endclass
