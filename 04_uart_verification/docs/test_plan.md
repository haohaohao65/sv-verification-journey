uart_tx:

| 信号             |   方向      |   作用         |
|-----------------|--------------|----------------|
| `clk`           | input       | 系统时钟         |
| `rst`           | input       | 高有效复位       |
| `s_axis_tdata`  | input       | 待发送数据       |
| `s_axis_tvalid` | input       | 输入数据有效     |
| `s_axis_tready` | output      | DUT 可以接收数据 |
| `txd`           | output      | UART 串行输出    |
| `busy`          | output      | TX 正在发送      |
| `prescale`      | input       | UART bit 时间参数|
（本次测试固定DATA_WIDTH=8）

test1 ： Reset
验证目标：验证README和RTL定义的reset后状态，以及发送过程中reset的行为
检查：rst=1时，期望s_axis_tready=0，txd=1，busy=0；
检查：发送过程中rst变为1，期望dut回到idle（txd=1，busy=0）；

test2 : AXI4-Stream Handshake
检查：tvalid && tready 发生握手，DUT 接受这一拍的 tdata；
检查：s_axis_tvalid=1，s_axis_tready=0时，s_axis_tdata不发送；
检查：发送过程中改变s_axis_tvalid，验证 DUT 在 busy/发送期间不会错误接受新数据；
检查：发送过程中改变s_axis_tdata，如果已经完成握手，DUT 应该已经把这一个数据字存入自己的 data_reg，之后上游再改变 tdata 不应该改变当前正在发送的帧；

test3 : Prescale / Bit Timing
发送数据的一位UART bit的时间为prescale*8；
检查：不同 prescale，测量一个 UART bit 持续多少个 clk；
检查：空闲时修改 prescale；发送过程中修改 prescale；

test4 : UART Frame
检查：Start + DATA + Stop对于DATA_WIDTH = 8，应该是1 + 8 + 1 = 10 bits，其中start = 0，
data  = LSB first，stop  = 1；
检查：每个 bit 的持续时间是否正确；

test5 : 连续发送
检查：连续发送时是否不丢数据、不重复、顺序正确、帧之间边界正确；同时检查busy和s_axis_tready的时序关系