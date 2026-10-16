# 路科 APB-I2C 控制器 UVM 功能验证

建立日期：2026-10-16。定位：实习简历主项目，替代原 APB-UART 路线。当前仅建立学习入口、范围与材料记录；已独立编译课程 DUT，尚未实现本项目验证环境或完成 APB/I2C 功能仿真。

- [总计划与实际进度评估](../LEARNING_PLAN.md)
- [当前任务](../CURRENT_TASKS.md)
- [课程来源与本机编译记录](docs/SOURCE.md)

## 项目对象与角色

使用本人指定的路科“虚拟项目 I2C”资料，起点为 TB_00 的 rkv_DW_apb_i2c。课程提供 DUT、寄存器文档、APB3/I2C agents 和 TB_00～TB_05 参考版本。先读接口和规格，再逐步写主要验证代码；参考现成 agent 时标明复用/修改范围，不把课程完成版当成独立开发。

DUT 是 APB slave 与 I2C controller/master。验证端包括 active APB master agent、reactive I2C target/slave、独立 I2C bus monitor、寄存器/事务参考模型和 scoreboard。APB 成功访问只说明配置或命令被接口处理，I2C 是否发完、是否 ACK、数据是否正确、最终状态是否符合规格需要分别检查。

保留课程默认 pclk/ic_clk 和各自复位连接，首版不新增时钟比例/CDC 专项。核心期望来自规格、APB 命令与已知从机数据，通过实际总线和 APB 读回验证，不从 DUT 内部 debug/移位寄存器取答案。

## 范围分层

| 层次 | 内容 | 验收重点 |
|---|---|---|
| P0：先跑通 | APB 基础寄存器；I2C 主机、7 位地址、Standard-mode；单地址、单 byte 写和读 | 独立总线解码、APB RX 读回、自动比对、完成/失败/超时 |
| P1：寒假项目 | 短 burst、地址/数据 NACK、最后一字节 NACK、复位取消/重启、repeated START、有限 clock stretching；必要状态/基本中断 | 逐项核对 DUT 参数支持和寄存器副作用，旧场景回归、覆盖缺口和错误检测能力 |
| P2：春季深化 | RAL frontdoor/predictor、FIFO/中断边界、更多异常与随机场景；之后再评估一类高级特性 | 精确说明新覆盖范围，不重开另一大型项目 |

10 位地址、多主仲裁、高速模式、DMA、DUT 从机模式、复杂 backdoor/DPI 和通用 VIP 产品化暂缓。课程含有这些代码/用例不代表首版必须同时完成。禁止自行假定未映射地址报 PSLVERR、忙时禁止所有写入等行为，先查本 DUT 文档和 RTL。

## 实现顺序

1. 固定 TB_00 与参数、读所需手册章节、画协议波形；独立 DUT 编译已通过，接着做最小顶层加载/复位。
2. 分步写 APB interface/item/sequence/driver/monitor/agent，先做安全的复位值读回；只在 PSEL && PENABLE && PREADY 完成沿采集事务。
3. 梳理控制、目标地址、数据/读命令、使能、状态/FIFO 寄存器；初版显式访问和轻量模型，不要求立即写全 RAL。
4. 写最小 reactive slave 的地址应答和数据应答，加入独立 I2C bus monitor；实现单 byte 写比对。
5. 从机返回已知数据，核对线上数据与 APB RX 读回；逐步增加 burst、NACK、重复起始、复位与拉伸。
6. 收紧期望/实际队列和完成条件，再加基础断言、功能覆盖率、回归及受控错误实验。

首版重点学 reactive response、两侧事务关联和寄存器副作用，复用既有 FIFO/UVM 的方法。读清楚之后再针对需要学习 virtual sequence/RAL，避免重做全部入门课程。

## 关键检查与测试点

- I2C SCL/SDA 按开漏和上拉建模，驱动只拉低或释放；monitor 观察实际解析后的总线。START/STOP 与普通数据变化分清，数据按 MSB-first 解码；ACK/NACK 驱动方随读写阶段变化。协议依据 [NXP UM10204](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)。
- 地址 ACK 与地址 NACK、写数据 ACK/NACK、读最后 byte 的主机 NACK 分开记录；预期 NACK 是协议用例，不等同检查器报错。
- APB 寄存器的 RW/RO、读清、写清和 FIFO 出入队按 DUT 文档处理，禁用/使能下配置限制单独列出；不要盲目做每个寄存器的写读或 bit-bash。
- APB monitor 与 I2C monitor 独立发布事务；模型根据已接受命令、目标地址、读写方向、预期数据和完成事件关联检查，不单纯比较两侧事务数量。
- 有限拉伸测试观察实际 SCL 的释放，不用固定延时假设一定上升；未声明的硬件超时恢复不能自行当成 DUT 必须支持的能力。
- 复位取消旧命令/半包及待比较事务，重新配置后下一包可正常完成；错误数不随复位清零。
- 结束同时确认所有必要命令、数据、RX 读回和总线终止已处理；队列排空要求按用例约定，不能用 Sequence 完成或固定 run 时长当成功。
- 审阅课程断言再使用，例如连续两次合法读可返回相同值，不能要求每次读回数据都变化。纯数字仿真不宣称模拟上升时间或完整电气认证。

## 最终交付证据

- [ ] 规格/测试点/检查器映射，明确本次版本、参数和未覆盖范围。
- [ ] 正常写/读、边界与异常定向通过，至少 10 个随机 seed 初步回归；保留 seed、配置、命令和日志。
- [ ] 协议断言、数据错误、随机化失败、UVM_ERROR/FATAL、超时均向回归传播失败；避免仅看进程退出码或 FINAL PASS。
- [ ] 功能覆盖包括方向、长度、地址/数据类别、ACK/NACK、复位阶段、重复起始和已声明拉伸；仅对已实现范围定义完成率。
- [ ] 两类受控错误实验被捕获，例如实验副本的数据破坏和握手/响应停滞；明确这是注入实验，原 DUT 保持不变。
- [ ] 能独立解释和小幅修改 APB driver、I2C monitor 或 scoreboard，讲清真实调试过程。

后续按阶段新增 dut/tb/sim/results 及具体规格/测试计划，当前不放入整套课程答案或代填 TODO。继续使用现有 ModelSim/UVM 1.2，本项目完整 UVM 环境的兼容性尚未验证。
