# 路科 APB-I2C 材料与可行性检查

核对日期：2026-10-16。本人指定课程为 E:/路科视频 中的路科 V2Pro Plus，不另选开源 DUT。

## 已定位的本地资料

课程根目录：`E:/路科视频/路科V2Pro_Plus/路科V2-PRO代码(已更新)/虚拟项目 I2C/`。

- `实验代码版本/rkv_v2pro_i2c-RKV_I2C_TB_00.zip` 至 TB_05：从起始版本到后续参考实现。
- `实验代码版本/rkv_i2c_vplan.xlsx`：课程验证计划，已确认文件存在；本次未读取工作表内容，不把其测试点记为已实现。
- `参考资料/DW_apb_i2c_databook.pdf`、`DW_apb_i2c_RGM_doc/index.htm`：课程提供的 DUT/寄存器参考。本次确认路径，尚未逐页审核，具体寄存器语义在第一阶段核对。
- `参考资料/NXP I2C Specification and User Manual.pdf`：协议参考；本次另核对 [NXP 官方 UM10204](https://www.nxp.com/docs/en/user-guide/UM10204.pdf)。

TB_00 压缩包 SHA-256：`cde57f1fa52f2ab547d84211e6e7ba59cbf372b3244294858d477ae01cf50d2c`。

## 已查看的项目结构

压缩包中 DUT 为 `rkv_dw_apb_i2c/src/rkv_DW_apb_i2c.v`，接口包含 APB3 的 PREADY/PSLVERR、pclk/presetn 与独立 ic_clk/ic_rst_n，以及 SCL/SDA 输入、开漏控制输出和中断/调试输出。

`rkv_i2c_tb/tb/rkv_i2c_tb.sv` 已展示开漏/上拉连接，默认 APB 时钟周期 4ns、I2C 核内部时钟周期 10ns；后者不是串行 SCL 周期。串行模式与速率需由实际配置和高/低计数确认。

课程包含 `agents/lvc_apb3`、`agents/lvc_i2c`、寄存器、env、seq_lib 和 tests。其 Makefile 使用 vlogan/vcs/simv，需适配本机 ModelSim。存在现成环境不代表本人的验证环境已完成或独立掌握。

## 本次实际独立编译

在工作区 `.scratch/apb_i2c_dut_check_698e8e59/` 中只提取原始 DUT 的 Verilog 源文件，按课程 `sim/rkv_i2c.flist` 的顺序编译；未复制/运行完成版 UVM 环境，未修改原课程目录。

- 工具：ModelSim SE-64 2020.4 的 vlib/vlog。
- 文件列表：28 个 Verilog 输入文件，使用原始源码。
- 结果：vlib/vlog 退出码均为 0；Errors: 0，Warnings: 0。
- [本次编译日志](../results/dut_compile_20261016.log)。
- [原始检查摘要](../../../.scratch/apb_i2c_dut_check_698e8e59/summary.json)。

这项证据仅确认 DUT 源码编译可行。顶层 elaboration/加载、复位、寄存器、I2C 功能，以及课程 agent/RAL 的 ModelSim 兼容性尚未验证；下一步逐项接通，不直接套用课程 VCS 命令。

课程资料作为本地学习参考，保留来源；本仓库先记录引用和自己的练习。复用/参考的组件与本人独立实现/修改的部分分别说明。
