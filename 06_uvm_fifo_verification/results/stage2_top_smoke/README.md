# 顶层连接与启动复位检查

日期：2026-10-11。工具：ModelSim SE-64 2020.4。检查范围为 interface/DUT 连接、启动复位及复位后空闲，尚未加入 UVM 或验证读写功能。

原始顶层第 32/33 行直接引用 `w_enb`、`r_enb`，编译报 vlog-2730 Undefined variable。仅修正为 `vif.w_enb`、`vif.r_enb`；重新编译 0 errors、0 warnings。

| 仿真时刻 | reset | empty | full | dout | w/r |
|---|---|---|---|---|---|
| 1ns | 1 | 1 | 0 | 0 | 0/0 |
| 16ns | 1 | 1 | 0 | 0 | 0/0 |
| 21ns | 0 | 1 | 0 | 0 | 0/0 |
| 31ns | 0 | 1 | 0 | 0 | 0/0 |

时钟周期 10ns，复位跨越 5ns/15ns 两个上升沿，在 20ns 下降沿撤销，35ns 调用 `$finish`。外部 Tcl 检查成功输出 `TOP_RESET_SMOKE_PASS`，仿真进程返回码 0。

日志：`compile_before.log` 为学习者原始版本编译错误，`compile_after.log` 为修正后的编译结果，`reset_smoke.log` 为成功仿真。外部检查脚本在 `../../sim/check_top_reset.do`；检查在边沿之外进行，用于本步稳定复位输出核对，不代替后续 clocking block 的周期采样方案。

复现：在项目根目录 PowerShell 执行：

```powershell
New-Item -ItemType Directory -Force sim/build/top_smoke | Out-Null
Push-Location sim/build/top_smoke
vlib work
vlog -sv -work work ../../../tb/fifo_if.sv ../../../dut/sync_fifo.v ../../../tb/tb_top.sv
vsim -c -onfinish stop -voptargs=+acc -l reset_smoke.log work.tb_top -do ../../check_top_reset.do
Pop-Location
```

本次并未检查未复位状态、短复位脉冲、数据读写或 UVM 组件。编译前确保 vlog 成功，再进入 vsim；输出 PASS 仅限上表检查范围。
