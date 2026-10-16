# 第三方 DUT 来源

- 作者：KRANTHI UPPADA。
- 上游仓库：https://github.com/kranthiuppada/synchronous-fifo
- 固定提交：`d216dd0ed92c5d92d0be2ede73a7ed492fcb810c`。
- 原文件：`sync_fifo.v`。
- SHA256：`0F75A9C1964804C32D92A6995A9264A9180E34CB2A4D6B36CD611600E385363B`。
- 许可证：MIT；完整原文保存在同目录 `LICENSE`。

该文件从固定提交的本地克隆按原始字节复制，未作修改；未复制上游 Testbench 或嵌套 Git 仓库。后续发现疑似问题，先用独立测试复现并记录；错误注入使用 `experiments/` 中的独立副本。

默认参数 Depth=8、Width=16。其他参数支持情况见 `../docs/dut_spec.md`；目前不将静态分析等同于参数功能测试通过。
