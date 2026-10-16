// UART TX DUT：把并行数据串行化为起始位 0、LSB-first 数据和停止位 1。
// 以下注释解释现有 RTL，不改变握手、计数或复位行为。
module uart_tx #(
    parameter DATA_WIDTH = 8
)(
    uart_if.dut_if u_if
);

    // 输出寄存器：ready 是输入接受状态，txd 空闲为 1，busy 表示发送忙。
    reg s_axis_tready_reg = 0;
    reg txd_reg = 1;
    reg busy_reg = 0;

    // data_reg 比数据宽一位，用于携带数据与高电平尾部；移位时先输出最低位。
    // prescale_reg 是当前位的倒计数，不是接口配置 prescale 本身。
    // bit_cnt 记录剩余发送阶段；它固定为 4 位，不表示本 RTL 支持任意 DATA_WIDTH。
    reg [DATA_WIDTH:0] data_reg = 0;
    reg [18:0] prescale_reg = 0;
    reg [3:0] bit_cnt = 0;

    // 连续赋值把内部寄存器连接到接口输出。
    assign u_if.s_axis_tready = s_axis_tready_reg;
    assign u_if.txd           = txd_reg;
    assign u_if.tx_busy       = busy_reg;

    // 同步时序逻辑：<= 的右值使用当前旧寄存器值，更新在非阻塞赋值阶段生效。
    always @(posedge u_if.clk) begin
        // 复位优先，取消当前发送并让 txd 回到空闲高电平；data_reg 没有在此清零。
        if (u_if.rst) begin
            s_axis_tready_reg <= 0;
            txd_reg           <= 1;
            prescale_reg      <= 0;
            bit_cnt           <= 0;
            busy_reg          <= 0;
        end
        else begin
            // 位时间尚未走完：逐拍递减，不推进数据位，ready 保持低。
            if (prescale_reg > 0) begin
                s_axis_tready_reg <= 0;
                prescale_reg      <= prescale_reg - 1;
            end
            // 无剩余发送阶段：进入空闲处理；下面 valid 分支可能覆盖本拍的默认赋值。
            else if (bit_cnt == 0) begin
                s_axis_tready_reg <= 1;
                busy_reg          <= 0;

                // 现有 RTL 在此检查 valid；ready 的反相使用旧值，不能按软件顺序解释。
                // 装入数据并拉低 txd 发起始位；(prescale<<3)-1 配合倒计数形成位时间。
                if (u_if.s_axis_tvalid) begin
                    s_axis_tready_reg <= !s_axis_tready_reg;
                    prescale_reg      <= (u_if.prescale << 3) - 1;
                    bit_cnt           <= DATA_WIDTH + 1;
                    data_reg          <= {1'b1, u_if.s_axis_tdata};
                    txd_reg           <= 0;
                    busy_reg          <= 1;
                end
            end
            else begin
                // 起始/数据位时间结束后，移出下一个数据位，并重新装载位倒计数。
                // 拼接赋值等效于 data_reg 右移，旧最低位送到 txd，最高位补 0。
                if (bit_cnt > 1) begin
                    bit_cnt      <= bit_cnt - 1;
                    prescale_reg <= (u_if.prescale << 3) - 1;
                    {data_reg, txd_reg} <= {1'b0, data_reg};
                end
                // 数据发送完，进入停止位。这里装载值没有减 1，busy 回空闲时序
                // 与起始/数据位有额外时钟差异；不要把停止位加空闲的整段高电平当位宽。
                else if (bit_cnt == 1) begin
                    bit_cnt      <= bit_cnt - 1;
                    prescale_reg <= (u_if.prescale << 3);
                    txd_reg      <= 1;
                end
            end
        end
    end

endmodule
