# 项目接续记录

更新：2026-10-16。开始新对话时同时读取仓库根目录 `AGENTS.md`。记录用于恢复项目进度，不代表新对话自动拥有旧对话的全部内容。

## 当前状态：2026-10-16 证据核对

- 当前主项目已按本人决定转向 [APB-I2C](../07_apb_i2c_verification/README.md)，FIFO 保留为 UVM 基础和回归基线，不重新从空 test 开始。
- 已有 item/sequence/sequencer/driver/monitor/agent/env/scoreboard/coverage 和多类 test；参考队列根据自身占用判断接受条件，源码默认 Depth=8、Width=16。
- [保存回归摘要](results/regression/run-0f35823f69ed/summary.json)：10-16 的 7 项定向（smoke/order/boundary/simultaneous/wrap/reset/burst）＋随机 seed 1/42/2026，共 10/10 PASS、UVM_ERROR/FATAL=0。这是 10 次运行、3 个随机种子。
- seed=2026 的 [当前覆盖报告](results/regression/run-0f35823f69ed/fifo_random_test_seed_2026.log.coverage.txt) 为 28/28 bins、covergroup 100%；仅限当前模型。覆盖来源/定义与最初详细计划仍有差异，不能宣称全部规格或参数空间均验收。
- 已保存 [漏读失败](results/stage3_missing_read.log)、[超时 FATAL](results/stage3_timeout.log) 和 [无效测试名失败](results/regression/run-4eb553a3364a/summary.json)。前两份旧底层脚本日志仍有 quit code 0，功能失败不能只看模拟器退出码；当前功能回归用 `sim/run_regression.ps1` 解析日志并给出判定。
- 不因代码存在推断独立掌握；未找到足够证据确认参数回归、所有规格项或 DUT 错误注入完成。本次未重跑任何已保存回归。
- 接续时先读根目录 CURRENT_TASKS.md。若回到 FIFO，只针对具体问题读相关源码，不重新扫描或重跑全部阶段。

## 2026-10-12 历史接续记录

以下保留当时状态；其中“空 test、未建立组件、下一步 run_phase”等描述不再作为当前进度。

- 学习方式：学习者先写主要代码，助手只分步教学、检查、最小修正与必要调试；日常优先快速静态审阅。
- 阶段一：已核对固定版本 DUT，完成规格/测试计划草案，见 `docs/`。原始 DUT 和已有 UVM hello 已实际运行相关编译/环境检查。
- `tb/fifo_if.sv`：学习者已写，独立编译 0 errors、0 warnings。
- `tb/tb_top.sv`：学习者已写；助手仅把初始化的 w_enb/r_enb 改为 vif.w_enb/vif.r_enb。顶层编译通过，启动复位和复位后空闲检查通过，证据在 `results/stage2_top_smoke/`。
- 时钟周期 10ns，复位过程计划在 20ns 撤销。此前普通顶层的 35ns $finish 已移除；当前空 UVM Test 在 0ns 结束，启动仿真尚未走到复位撤销，不代表 FIFO 读写功能验证通过。
- `tb/tests/fifo_test.sv`：已审阅；继承、factory 注册和 super.new 正确。助手仅删除构造函数前的 virtual，修正 vlog-2620 警告；实际编译 0 errors、0 warnings。
- `tb/fifo_tb_pkg.sv`：助手此前修正 include 路径并移除类文件内重复导入。现已与接口、DUT、顶层集中编译，0 errors、0 warnings。
- UVM 启动：学习者已写包导入和 run_test，助手仅将 run_test 从复位过程末尾移到独立 initial。实际日志在 0ns 出现 Running test fifo_test，UVM_WARNING/ERROR/FATAL 均为 0；证据为 results/stage2_uvm_start.log。本机批处理脚本 sim/run_uvm_start.do 从项目根目录执行，沿用 UVM 1.2/UVM_NO_DPI 配置；此脚本仅供启动练习，不是最终功能回归判定器。
- 当前任务：学习者在 fifo_test 内实现 run_phase，以 raise_objection、教学用 #30ns 等待和 drop_objection 观察生命周期，打印开始/结束时间。该延时只用于 phase 练习，不用于 DUT 输出采样或最终完成判定；后续再学习 virtual interface/config_db 以按实际复位和事务完成状态等待。还未建立 driver、monitor、scoreboard 或 coverage。
- 原始第三方 RTL 尚无独立复现的 Bug 证据；尚未进行 FIFO 功能回归、参数回归或错误注入。
- 学习仓库有既存未提交修改；未 Commit/Push，不要自动清理或提交其他学习内容。
