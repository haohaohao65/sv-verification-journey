# 第三方同步 FIFO：阶段一规格草案

日期：2026-10-11。依据固定版本源码的静态分析；功能行为仍需独立仿真验证。此文档供学习者审阅，不表示整个 FIFO 已通过验证。

## 1. 来源与证据

- 上游：https://github.com/kranthiuppada/synchronous-fifo
- 提交：`d216dd0ed92c5d92d0be2ede73a7ed492fcb810c`。本地 HEAD 与本次 `git ls-remote origin refs/heads/main` 返回值一致。
- 项目内源码：[sync_fifo.v](../dut/sync_fifo.v)。来源记录见 [UPSTREAM.md](../dut/UPSTREAM.md)。
- 源码 SHA256：`0F75A9C1964804C32D92A6995A9264A9180E34CB2A4D6B36CD611600E385363B`。
- MIT License，Copyright (c) 2025 KRANTHI UPPADA。后续复制 DUT 必须同时保留完整 LICENSE、文件原貌和来源记录。
- README 将文件称为 `fifo.v`/`fifo_tb.v`，并列出实际不存在的目录；实际文件为 `sync_fifo.v`/`sync_fifo_tb.v`。
- 17 页设计报告已提取文字并查看页面概览，重点检查第 6 页代码和第 11 页同时读写波形。报告第 6 页在两个时序块中写 `count`，实际源码只用一个时序块。报告属于背景资料，不能替代当前版本源码。
- 上游 TB 在 `@(posedge clk)` 后用阻塞赋值改变使能和数据，与 DUT 的 Active 区读取存在竞态；主要用显示和波形观察，没有独立自动数据比较。其结果不是正确性证据。

## 2. 接口

| 名称 | 方向/默认宽度 | 本项目行为定义 |
|---|---|---|
| `clk` | input，1 bit | 单时钟；上升沿进行读写 |
| `reset` | input，1 bit | 高有效、异步断言；复位优先于读写 |
| `w_enb` | input，1 bit | 写请求，不等于已接受写入 |
| `r_enb` | input，1 bit | 读请求，不等于已接受读取 |
| `din` | input，Width bits | 有效写入时锁存 |
| `dout` | output reg，Width bits | 有效读取的同一上升沿后更新；其他周期保持，复位清零 |
| `empty` | output wire，1 bit | `count == 0` |
| `full` | output wire，1 bit | `count == Depth` |

默认 `Depth=8, Width=16`，源码时间单位/精度为 `1ns/1ps`。没有读有效、写应答、占用数量、溢出或下溢输出；`dout` 不是组合显示队首的接口。

## 3. 独立行为规则

记 `q_pre` 为参考队列在本次上升沿前的元素数量，`D=Depth`。在复位无效且输入为已知 0/1 时：

```text
accept_w = w_enb && (q_pre < D)
accept_r = r_enb && (q_pre > 0)
q_post   = q_pre + accept_w - accept_r
full_post  = (q_post == D)
empty_post = (q_post == 0)
```

两个接受条件必须先根据同一个旧状态计算。不得先 push 再用新队列非空判断读，或先 pop 再用新队列未满判断写。DUT 的 full/empty 只作为被检查的观测值，不能替代以上独立条件。

| 边沿前占用 | 请求 `(w,r)` | 预期接受 `(w,r)` | 边沿后占用 | 预期 dout |
|---|---|---|---|---|
| 0 | 00 | 00 | 0 | 保持 |
| 0 | 10 | 10 | 1 | 保持 |
| 0 | 01 | 00 | 0 | 保持 |
| 0 | 11 | 10 | 1 | 保持；不直通 din |
| 0 < q < D | 00 | 00 | q | 保持 |
| 0 < q < D | 10 | 10 | q+1 | 保持 |
| 0 < q < D | 01 | 01 | q-1 | 旧队首 |
| 0 < q < D | 11 | 11 | q | 旧队首 |
| D | 00 | 00 | D | 保持 |
| D | 10 | 00 | D | 保持 |
| D | 01 | 01 | D-1 | 旧队首 |
| D | 11 | 01 | D-1 | 旧队首；本次 din 丢弃 |

实现 Queue 模型时，可在预先保存两种接受条件后先 pop 旧队首、再 push 新数据。中间状态同时读写不会把当拍输入当成读出值。满时同时读写不接收新写入，即使本拍读取释放了空间。

维护独立的 `expected_dout`：复位为零，接受读时更新为弹出的旧队首，否则保持。每个完成采样的周期均可比较 DUT dout 与该值；被拒绝的读不做队列 pop，但仍须检查输出保持。

## 4. 复位

源码第 24-29 行说明：`posedge reset` 不需要等待时钟即可安排清零 wptr、rptr、count、dout；更新在 NBA 中完成，组合 full/empty 随后稳定为 0/1。高电平期间的时钟边沿继续执行复位分支。

复位不清存储数组。逻辑队列必须清空；复位前的数据已失效，不能要求内部 memory 全零，也不能再次读出这些数据。复位撤销的下降沿不触发该 always 块；撤销后第一个正常上升沿可接受操作。

本项目激励约定：控制/数据是已知值，复位撤销避开上升沿；正常读写驱动只在规定的驱动时刻发生。RTL 仿真无法证明实际硬件复位撤销的 recovery/removal 或亚稳态行为。

如果复位短脉冲完全落在两个上升沿之间，只在时钟上升沿取样的 Monitor 会漏掉它。后续需要独立 reset 事件观测，将模型清空，并以明确的调度方式检查异步断言后的输出；不能仅在下个时钟检查后就声称已验证异步特性。时钟/复位观测写入统一有序检查流，约定复位优先和取消规则。

复位前未初始化状态可能为 X；检查器在观察到有效复位并完成更新后开始正常功能检查。观测字段用四态 logic，比较需检测 X/Z，不能用 bit 转换掩盖未知输出。

## 5. 调度和采样设计

推荐后续实现一个 Monitor 时钟采样 clocking block，在同一个 posedge 中分别声明：

- 请求和旧状态：`input #1step` 采样 reset、w_enb、r_enb、din，及用于诊断的旧 full/empty。
- 结果：`input #0` 采样 dout、full、empty，并考虑边沿后 reset 的诊断采样。
- Monitor 用 `@(vif.monitor_cb)` 等待 clocking block 事件，再读取 clocking block 采样变量，形成一份带 cycle_id 的边沿记录。不要改成等裸 `posedge clk` 后马上读原始输出。

`#1step` 表示边沿前的采样值；显式 `input #0` 在 Observed 区采样，能够看到本 RTL 的 NBA 更新及其后稳定的组合状态。它与过程语句 `#0` 不同：后者通常只移到 Inactive 区，仍早于 NBA。此处不使用任意 `#1` 去碰巧等待输出。

时序关系：

```text
前一个下降沿：Driver 驱动请求 → 上升沿前 #1step 采样旧值
上升沿 Active：DUT 计算条件与 NBA 右值
NBA：更新 dout/指针/count → 组合标志重新求值
Observed：clocking input #0 采样结果 → Monitor 发布完整周期记录
```

Driver 推荐使用下降沿的驱动 clocking block、output #0，在随后的上升沿前使请求稳定。一个 item 先定义为一拍请求；持续使能跨越几个上升沿，就表示几个请求，不能仅监测信号变化。复位由单一控制来源驱动，避免多个线程争用。

依据：[Accellera 时钟块输入采样条款澄清](https://www.accellera.org/images/eda/sv-ec/att-3008/SV-890-1.htm)，[Accellera input skew 讨论](https://www.accellera.org/images/eda/sv-ec/7951.html)。这些资料用于解释调度原理；阶段二还需通过本机小练习确认采样和事务对齐。

异步 reset 的事件也需要在其 NBA 完成后检查；不能把裸 reset 事件上的 Active 区输出当成最终值。具体事件 clocking block 和串行化机制留到实现阶段分步设计。

## 6. 参数支持与风险

| 参数配置 | 静态结论 | 验证安排 |
|---|---|---|
| Depth=8, Width=16 | 默认配置；源码已独立编译 | P0/P1 首先使用 |
| Depth>=2 的适度整数，Width>=1 | 指针位宽可表示合法地址；用 `% Depth` 明确回绕 | 待参数仿真，不宣称任意参数均通过 |
| Depth=3/5 | 源码没有直接限制为 2 次幂；应有意验证 | P2 候选，先检查 elaboration 和多轮数据顺序 |
| Depth=1 | `$clog2(1)=0`，指针声明成为 `[-1:0]`，不是预期的零宽向量 | 扩展调查，暂不纳入正式支持范围；不直接宣称必然编译失败或已发现 Bug |
| Depth<=0 或 Width<=0 | 没有合法用途，也没有参数检查；异常范围可能仍被工具接受 | 排除常规功能回归，必要时记录参数保护缺失 |

`(wptr + 1) % Depth` 中的未定宽整数常量使表达式不能简单按指针窄位宽溢出来推断；对于上述小深度不能把 `% Depth` 忽略。非 2 次幂取模的综合成本也不等于功能错误，本项目不承担综合/PPA 评估。

默认深度下指针 3 bit，count 4 bit，可表示 0..8。目前静态检查未建立实际 DUT Bug 的复现证据。

占用量不是 DUT 输出。黑盒检查只能用参考队列数量预测标志，再通过后续数据检查暴露计数/指针问题；不能声称每拍直接比较了 DUT count。需要内部定位时可额外观察 count/wptr/rptr，但不能让参考模型依赖这些信号。

## 7. 尚未完成

- 学习者对行为表、时序和独立模型的解释与确认。
- Clocking block 的本机采样练习和异步 reset 事件实现。
- 全部独立功能仿真、参数 elaboration/回归、覆盖率、错误注入。
- 最终项目目录和提交范围确认。

未完成项不得记为功能通过。
