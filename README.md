# IC 验证学习仓库

当前主线（2026-10-16）：已有 UART/SV 与 FIFO/UVM 基础 → APB/I2C 协议 → 路科 APB-I2C 主机写/读 UVM 验证闭环 → 寒假实习冲刺 → 春季深化 → 暑假实习。

## 从这里开始

- [学习计划与实际进度评估](LEARNING_PLAN.md)：根据 10-16 证据调整后的目标、范围、时间和验收。
- [当前任务](CURRENT_TASKS.md)：10-16—10-22 的协议、寄存器与最小顶层练习。
- [APB-I2C 项目入口](07_apb_i2c_verification/README.md)：路科课程来源、分步实现和验收标准。
- [学习日志](LEARNING_LOG.md)：自 10-06 已开始正式记录，历史日记与运行证据保留。

## 项目定位

| 目录 | 用途 |
|---|---|
| `01_sv_basic` | 按项目短板回查 SV 基础 |
| `02_alu_verification` | 复习类式验证结构 |
| `03_fifo_verification` | 复习 FIFO、参考模型与断言 |
| `04_uart_verification` | 保留已有 UART TX 学习基线与已知缺口 |
| `05_uvm_basics` | 已有 UVM 分步练习，按需复习 |
| `06_uvm_fifo_verification` | 已建立 UVM 功能验证与回归基础，接续见 PROGRESS.md |
| `07_apb_i2c_verification` | 简历主项目：基于路科 DUT 分步编写自己的验证内容 |

旧 APB-UART 简历项目路线已取消。计划不等同已完成；当前源码与保存的历史日志需分别说明。学习者先写主要代码，助手负责必要讲解、审阅与调试，不一次性生成整套环境。
