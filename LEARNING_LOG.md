# IC 验证学习日志

创建日期：2026-10-05
状态：已开始正式记录。
开始记录日期：2026-10-06（按本人最新要求提前启动）。
维护方式：由 Codex 结合相关 Codex / ChatGPT 学习对话、实际代码产出和验证结果整理。

## 学习目标

逐步掌握 IC 验证，能够独立完成中小型模块的验证。

路线参考 [学习计划](LEARNING_PLAN.md) 和 [当前任务](CURRENT_TASKS.md)。2026-10-16 按本人决定改为路科 APB-I2C 简历主项目；保留已有 UART TX 与 FIFO UVM 基础，继续 APB/I2C 协议及端到端验证。以下历史日记保留当时的路线，未补造缺失日期的学习记录。

## 项目进度

根据实际记录更新，不将计划当作已完成。

| 项目 | 当前阶段 | 已完成 | 当前问题 | 下一步 | 验证证据 |
|---|---|---|---|---|---|
| UART TX | 学习阶段基线保留 | 正常/复位记录、continuous 4 帧比对、部分位宽与 SVA | 位宽范围、精确计数/队列清空仍有历史缺口 | 按需复习，不扩为简历主项目 | 2026-10-06、10-07 日记与现有 transcript |
| UVM 基础 | 已进入完整组件实践 | 05_uvm_basics 有 01～30 源码；FIFO 已使用 phase/config_db/analysis 等机制 | 未逐一重跑所有基础练习 | 按 APB-I2C 需要定点复习 | 05_uvm_basics 源码及 FIFO 运行证据 |
| FIFO UVM | 功能回归与覆盖率基线 | 10-16 保存的 7 项定向＋3 个随机 seed 共 10/10 PASS；seed=2026 当前 covergroup 28/28 bins 命中 | 参数回归、完整规格覆盖和 DUT 故障注入未确认 | 保留基线，将验证方法用于 APB-I2C | [接续记录](06_uvm_fifo_verification/PROGRESS.md) 与其中原始日志 |
| APB-I2C | 课程定位与 DUT 编译 | TB_00 的 28 个 Verilog 输入文件在本机独立编译，0 errors/0 warnings | 顶层加载/复位、APB/I2C 功能及课程 UVM 兼容性尚未验证 | 核对协议和寄存器，写最小顶层与访问 | [来源与本次编译记录](07_apb_i2c_verification/docs/SOURCE.md) |

当前状态表于 2026-10-16 根据源码和保存日志更新；本次仅新运行 APB-I2C DUT 独立编译，未重跑已有 UART/FIFO 回归。运行证据与学习日期分别说明，表格不替代各日期的学习日记。

## 每日学习记录

按以下模板追加；当日记录放在模板之后。

```markdown
### YYYY-MM-DD｜学习主题

记录时间：YYYY-MM-DD HH:mm（北京时间）
最后更新：YYYY-MM-DD HH:mm（北京时间，仅修改时填写）

#### 关键知识点
- 知识点名称：
- 用途与应用场景：它用来做什么，为什么在项目中需要它。
- 正确解释：概念、原理及必要的适用条件。
- 使用方法与易错点：最小示例、语句含义及注意事项。
- 对应的小例子或实践位置（有助于复习时填写）：

#### 学习内容
- 项目背景、当日目标和练习顺序：

#### 代码进展
- 文件位置、改动前的问题、具体改动及目的：
- 实现状态与剩余工作：

#### Debug 结论
- 测试场景与故障现象 → 根因及执行路径 → 修改及结果：
- 排查经验或未解决的问题：

#### 验证结果
- 验证目标、场景和代码版本：
- 运行命令、结果及日志 / 波形来源：
- 关键计数或覆盖率的含义、预期与实际是否一致：
- 尚未验证的范围：

#### 项目进度与下一步
- 本次完成：
- 当前卡点：
- 下一项任务：
- 后续复习或实践主题：
```

### 2026-10-06｜UART TX：测试选择、复位取消与覆盖率

记录时间：2026-10-06 21:41（北京时间）
最后更新：2026-10-06 22:11（北京时间）
依据：《代码学习》《对话教学》、TX 源码与 transcript。

#### 关键知识点

**1. plusargs：启动时选择测试。**
plusargs 是启动命令中以 + 开头、供验证代码读取的参数；用它选择测试，无需每次换场景都改源码。

`vsim work.tb +TEST=reset_data` 表示加载顶层 tb，并传入 TEST 参数。它不驱动 DUT；Generator 读取名字再设置复位延迟。

`$value$plusargs("TEST=%s", test_name)` 是 SV 系统函数：寻找匹配参数，`%s` 按字符串读取，结果存到 test_name；找到返回1，没有找到返回0。
`if (!$value$plusargs(...)) test_name="normal";` 中，`!` 取反：未提供参数才设默认值，函数不会自动设 normal。string 保存文字，==比较字符串内容。未知名字用 $fatal报错，防止拼错后悄悄跑正常测试。

**2. 脚本参数接到 SV 参数。**
在 ModelSim Transcript 输入 `do run.do reset_data`：脚本用 `$1` 取得首个参数 reset_data，再传给 `vsim ... +TEST=reset_data`，SV plusargs 才读到它。$1是脚本规则，不是 SV 系统函数。
run.do默认 normal；已有仿真时先 `quit -sim`，再 `do run.do 测试名`；`-onfinish stop` 保留窗口供看结果，`run -all` 运行到结束或暂停。

**3. 停止位中心采样不等于帧完整结束。**
8位 UART 帧：起始位0 → 8位数据低位先发 → 停止位1。位时间为 prescale×8拍，prescale=4时为32拍。
如果 Monitor 在停止位中心采样后立即提交帧，就会漏检停止位后半段的复位：解码字节正确，但帧尚未完整发送。
当前验证目标是“停止位完整结束前发生复位就取消帧”。Monitor 先检查起始/停止位中心采样，再等停止位剩余半位，期间逐拍观察复位，最后提交数据或通知取消。不能简单把最后一位也等待整个位，否则多等半位。先检查格式，避免后续复位掩盖错误；仍需独立位时间检查。

**4. Coverage统计场景，Scoreboard检查正确性。**
axi_cg 在 valid&&ready 握手时统计接受输入；uart_cg 统计完整串行输出。55握手后被复位中断，输入覆盖仍命中55，输出不采这个半帧。因此两个覆盖组分别描述“接受了什么”和“完整发出了什么”，应同时保留。
bin 是覆盖目标，不产生激励。原先01～FE放在一个 bin，55出现就能命中，无法证明AA也出现。今天把00/FF/55/AA各设一个 bin，prescale=1/4/8也分开。
cross（交叉覆盖）统计多个覆盖点的组合。今天的数据×prescale 共4×3=12个组合。数据和配置必须取同一笔 UART transaction，避免把上一帧数据与下一帧配置拼在一起。
`get_coverage()` 返回百分数，不再乘100；`%0.2f%%` 保留两位小数并打印%。100%只表示定义的目标全部命中，数据对不对仍由 Scoreboard 比较。

**5. 结束条件与取消数检查。**
driver 等 busy=0 或复位输出检查通过只证明局部行为；Monitor 通知、Scoreboard 比较和覆盖采样也要完成，最终无 Fatal，才能判断本次测试结束成功。
expected_frames是计划帧数；完整帧与取消帧分开计数。Generator done仅表示激励生成完，不代表 DUT 发完。
expected_canceled 来自测试计划，sco.canceled 来自实际通知；normal应为0，其余五种测试为1。不一致就 $fatal；不能从实际数设置预期，否则任何实际结果都能通过。

#### 学习内容

UART TX 收尾：完善复位边界，用 string、plusargs 和脚本选测试，细化覆盖点、检查取消数量，形成可重复的测试流程。

#### 代码进展

工作目录：04_uart_verification；组件在 tx_verification，启动脚本在 sim。
- generator.sv：生成00/FF/55/AA，分别配 prescale=1/4/8，共12个目标帧。按测试名设置复位：normal无中途复位；reset_start/data/stop/stop_late 在第二组55握手后等待8/80/300/308拍；reset_last在最后一帧AA握手后等80拍复位。
- uart_monitor.sv：完整观察停止位后再提交；取消半帧时通知 Scoreboard，但不送入输出覆盖。
- coverage.sv：分开采样输入/输出，新增12个交叉组合；tb.sv打印计数、覆盖率并检查实际取消数。
- run.do：统一编译、选测试、运行、保留窗口。另补注释、缩进；对话记录原语句功能未改。

#### Debug 结论

现象：最后一帧复位后打印 Mid-frame reset check passed，却最终出现 TX test timeout。前者表示 driver 的复位输出检查通过，后者说明整体处理未完成。
根因：把后续“提交或取消”误嵌入 if(frame_valid)；数据位复位已使 frame_valid=0，整个分支跳过，Scoreboard 等不到最后一笔取消通知。
修复：移动 end，使格式检查、剩余半位等待、提交/取消分别判断；最后一帧取消后也能结束。经验：begin/end 层级决定执行条件；不同复位位置的路径不同，共用 Monitor 修改后要回归旧场景。

#### 验证结果

今日21:14本地 transcript 的 normal 汇总：Expected=12、AXI=12、UART=12、Checked=12、Pass=12、Fail=0、Canceled=0；三个打印覆盖率均100%，取消数预期/实际0/0。12帧均接受、完成且比对通过。
《代码学习》另外记录六项回归通过。复位测试预期接受12帧、完成并比较11帧、取消1帧；cross为91.67%（11/12），取消帧组合未完整输出，是预期缺口。
本次未重跑；源码未提交，仅支持今日场景，不代表全部验收。

#### 项目进度与下一步

正常/复位测试已可重复运行，有计数与覆盖检查。独立位时间和连续发送仍待验证：解码字节正确不能证明每个位持续时间正确；driver逐帧等 busy结束也不能证明连续握手行为。
下一步补位时间与连续发送检查，再保留 SV 基线、学 UVM 并迁移 TX，之后学 APB；今天未实现 UVM。


### 2026-10-07｜UART TX 收尾与首个 UVM test

记录时间：2026-10-07 21:28（北京时间）
依据：《代码学习》《UVM概念学习》、源码与日志；未重跑。

#### 关键知识点

**1. 类与构造函数：UVM语法基础。**
`my_counter h;`声明句柄，`h=new();`创建对象，h.count访问成员；extends继承父类成员。
构造函数`function new(int n);`无返回类型；new(10)用`this.count=n;`初始化。this指当前对象，super访问父类部分；super.new先初始化父类成员，再设置子类step，属于同一对象。

**2. 包、导入与宏：使用UVM库。**
UVM是SV类库；uvm_test测试基类继承uvm_component组件基类。
`import uvm_pkg::*;` 导入包里的名称；::指定作用域，*为通配导入。库仍需在脚本中编译配置。
`include "uvm_macros.svh"` 带入宏定义；语句前需反引号。Macro（宏）编译前展开为代码，调用也用反引号。uvm_component_utils(hello_test)注册宏提供工厂创建支持，注册不创建对象。

**3. 工厂与run_test：创建并组织测试。**
工厂登记类型并创建对象；`run_test("hello_test");` 按登记的类名，通过工厂创建测试对象，执行 new，再启动阶段调度。run_test是入口任务，与run_phase不同。
类名hello_test，实例名uvm_test_top；构造函数接收 `string name, uvm_component parent`，再 `super.new(name,parent);` 完成名字和层次初始化。
extends是类继承，parent是实例上级。test传parent=null，由UVM组织在根组件下。this访问当前对象，get_name()返回实例名；切换阶段不重新new。

**4. Phase：按阶段安排组件的工作。**
简化流程：run_test→new→build→connect→run→check→report→收尾（省略部分阶段）。
- build_phase：创建子组件、获取配置。function，不能#延时或@等待。
- connect_phase：连接组件间的数据通道。
- run_phase：task，可等待、延时；组件并行驱动、观察、检查。
- check_phase：检查结束后的遗漏，如待比较队列；逐笔比较可在运行中做。
- report_phase：汇总结果，不等待DUT。

`virtual function void build_phase(uvm_phase phase);` 中，virtual 支持父类句柄调用子类重写的方法；void 表示无返回值；phase 是 UVM 传入的阶段对象句柄。UVM 自动调用该方法，`super.build_phase(phase);` 执行父类处理。new 是 SV 构造函数，不属于 Phase。

**5. Objection：保留运行阶段，直到必要工作完成。**
`phase.raise_objection(this);` 表示还有工作，暂不结束；工作完成后 `phase.drop_objection(this);` 撤回。相关请求全部撤回并满足结束流程后，阶段结束、终止剩余线程，不等forever自然返回。
当前 hello/build 练习没有耗时测试和 objection，因此0 ns结束合理。run_phase与objection仅讲解，未做耗时练习。

**6. 连续发送与SVA：检查握手。**
valid&&ready的采样沿才握手；阻塞时data/valid须保持到握手沿，沿后可换下一笔。DUT从锁存数据发送，不受后续输入变化影响。
接口 property 使用 `@(posedge clk) disable iff(rst)` 指定采样时钟与复位禁用；核心规则：
`valid && !ready |=> ($stable(data) && valid)`。
|=>检查下一拍；$stable比较相邻采样值，也检查握手拍。assert property是并发断言，assert(randomize())是立即检查；失败应明确处理，不自动增加Scoreboard失败数。无报错不证明前提发生过。

#### 学习内容

TX补连续发送、位宽与SVA；完成SV、UVM小练习。

#### 代码进展

- 04_uart_verification：Driver 的 continuous 保持 valid，依次送00/FF/55/AA，固定 prescale=4；Monitor 检查FF起始低电平和55的跳变间隔；uart_if 加入等待稳定性 property。
- 05_uvm_basics：01～04练习继承、创建、new、super.new；05打印hello UVM；06打印new/build_phase。run_uvm_hello.do指定文件和顶层，使用本机UVM 1.2。
- 正式项目移至E:/IC_Verification/apb-uart-uvm-verification，保留docs/README，rtl/tb/sim待开发，尚无完整DUT/UVM环境。

#### Debug 结论

SVA补采样时钟，删disable iff后的分号，加入valid保持，改用assert property跨拍检查。
启动使用 UVM_NO_DPI 与 -nodpiexports，绕开本机基础练习不需要的 C/C++ 编译依赖；此配置仅适用当前基础练习。脚本重复执行时出现 Cannot change directory while a simulation is in progress：-onfinish stop仍保留已加载设计，必须先 quit -sim 再运行脚本。

#### 验证结果

TX transcript：continuous计划/握手/完成/比较均4，Pass=4、Fail=0、Canceled=0；FF/55位宽预期与实际均32拍。AXI数据覆盖100%；prescale/cross=33.33%，只测4种数据×prescale=4，命中4/12组合，和复位无关。
UART Errors=0、Warnings=2：波形文件占用，改用备用文件。《代码学习》另记continuous及原六项回归通过。
UVM本地日志hello UVM、ERROR/FATAL=0，随后重复运行脚本有目录切换错误，整份日志并非零错误。《UVM概念学习》记录06通过，顺序new→build_phase；未重跑。

#### 项目进度与下一步

TX阶段收尾，位宽范围、精确计数/队列清空仍有缺口。进入UVM基础，下一步写run_phase与raise/drop objection，观察时间推进及结束，再增加组件对照TX数据流。

## 每周回顾

正式开始记录后填写。

- 本周能够独立解释或完成的内容：
- 选取 2～3 个知识点，不看笔记解释或完成小练习，记录仍卡住的地方：
- 仍需复习的问题：
- 下周优先任务：

## 记录约定

- 按“一个月后不翻原对话也能看懂”写：交代项目背景与测试目标，解释首次出现的术语，具体说明自己做了什么、为何这样做；Debug 写出因果链，验证结果解释数字含义，下一步说明尚缺什么。其他栏目也需完整表达，不只堆变量名或结论。
- 日志作为复习资料：只记录经核实的知识、方法与实践结论，不记录本人的原判断、提问、理解对比或掌握程度评估。
- 知识点说明包含“用途 → 应用场景 → 正确原理 → 例子与语句含义 → 易错点”；代码进展写明动作与目的，让读者无需翻对话即可回忆。
- 优先收录首次遇见的语法、系统函数与术语，解释用途、最小示例、返回值或易混点，不只列名称。
- 正确解释需核对相关代码、语言语义或可靠资料，保留必要条件；历史助手回复不自动视为正确答案。不确定的结论注明“待核实”。
- 每周选 2～3 个知识点回顾；需要继续学习的内容以复习主题或实践任务记录，不复述原提问。
- 以学习为主，优先记录当天新知识、正确方法与易错点；关键知识点放在最前面，并占主要篇幅。
- 代码进展、Debug 结论和验证结果作为学习的实践佐证，写清过程和意义；关键知识点仍占主要篇幅。
- 每日使用独立栏目：关键知识点、学习内容、代码进展、Debug 结论、验证结果、项目进度与下一步，不混写。
- 知识点记录概念与易错点；代码进展记录文件和实现变化；Debug 结论记录故障根因和解决方法；验证结果记录实际检查及证据。同一事实不重复展开，没有内容的栏目写“无新增”或“未运行”。
- 每条日志标明学习日期和实际记录时间（北京时间）；补记使用真实学习日期与补记时间，后续修改标注最后更新时间。
- 每日记录不超过 3000 字，标题、正文及代码片段均计入；以一个月后仍能看懂为标准，不为压缩篇幅省略必要背景、例子和过程，也不凑字数。
- 只保留关键知识点、实际代码进展、重要 debug 结论、验证结果和下一步；长代码、完整日志及详细讲解用文件或对话引用代替。
- 同一天的新内容合并到该日记录，合并后仍不超过 3000 字。
- 区分讨论过、代码已实现和验证已通过。
- 以实际对话、代码和运行结果为依据，不推测学习时长或掌握程度。
- 历史回填注明来源；Git 提交日期不直接作为学习日期。
- 无法读取或尚未验证的内容明确标注。
- 2026-10-06 按本人要求提前整理，今晚定时任务停用；后续定时安排另行确定。
