# 第三方同步 FIFO 的 UVM 功能验证

目标：由学习者逐步编写 SystemVerilog + UVM 验证平台，掌握独立参考模型、正确采样、自动检查、测试结束条件与功能覆盖率。

当前状态（2026-10-16 核对）：已有 UVM 平台、独立参考队列、自动检查、功能覆盖率和回归入口。保存回归为 7 项定向＋3 个随机 seed，共 10/10 PASS；seed=2026 当前 covergroup 为 28/28 bins 命中。完整规格、参数空间和 DUT 错误注入未全部验收。详见 [PROGRESS.md](PROGRESS.md)；当前学习主项目已转为 [APB-I2C](../07_apb_i2c_verification/README.md)。

## 目录

```text
06_uvm_fifo_verification/
├── dut/                 # 原始 sync_fifo.v、MIT LICENSE、来源记录
├── docs/                # DUT 规格和验证计划
├── tb/
│   ├── fifo_*.sv         # 已有 item、agent、env、模型/scoreboard、coverage 和 sequences
│   ├── tb_top.sv         # 当前顶层
│   └── tests/            # 已有定向与随机 UVM tests
├── sim/                  # Tcl 编译/仿真与 PowerShell 回归；生成物放 build/
├── results/              # 分阶段及 regression 运行证据
└── experiments/          # 原先预留的错误注入练习位置
```

`fifo_if.sv`、`tb_top.sv`、`fifo_tb_pkg.sv` 和主要组件当前均在 `tb/` 下。空目录中的 `.gitkeep` 仅用于让 Git 保存目录，不是验证代码。

## 从这里开始

- [DUT 规格与采样方案](docs/dut_spec.md)
- [验证计划](docs/test_plan.md)
- [DUT 来源与许可证说明](dut/UPSTREAM.md)
- [阶段一检查结果](results/stage1/stage1_checks.md)

当前从 PROGRESS.md 接续。接口/参数与空、非空非满、满状态行为可作为独立复习，已完成的环境不要求重写。

## 原始 DUT 编译

在本项目目录打开 PowerShell，使用本机 ModelSim 命令：

```powershell
New-Item -ItemType Directory -Force sim/build | Out-Null
Push-Location sim/build
vlib work
vlog -work work ../../dut/sync_fifo.v
Pop-Location
```

本机已验证工具为 ModelSim SE-64 2020.4。此命令仅编译 DUT，不代表功能测试通过。当前已有 UVM 仿真和回归脚本；使用本机 UVM 1.2 源码配合 `UVM_NO_DPI`，安装目录默认 mtiUvm 则映射到 1.1d，不能混用版本。

阶段一日志记录了当时的绝对路径，属于历史运行证据；移动工程后请以当前项目目录执行新的编译和仿真。

## UVM 运行入口

已完成项目包和顶层的 UVM 启动检查。进入本项目目录后，可在 PowerShell 执行：

```powershell
vsim -c -do 'do sim/run_uvm_start.do'
```

脚本使用本机 UVM 1.2 源码，生成文件放在 `sim/build/uvm_start/`。10-12 的空 test 在 0ns 结束属于历史启动证据，当前 test 已有功能流程。底层 Tcl 入口主要负责编译/运行，功能回归及失败退出码使用 PowerShell 的 `./sim/run_regression.ps1`；默认包括 7 项定向和 seed 1/42/2026，不直接以底层 Tcl 退出码判断功能通过。保存结果见 `results/regression/run-0f35823f69ed/`；无修改时不必重复运行。
