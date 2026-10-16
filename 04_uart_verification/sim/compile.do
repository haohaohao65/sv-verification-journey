# ModelSim Tcl 脚本：只负责建库和编译，不启动测试。
# work 保存编译结果；filelist.f 决定文件顺序；-sv 启用 SystemVerilog，
# -mfcu 把本次输入文件作为一个编译单元处理，便于当前类定义互相引用。
# 若 work 库不存在，创建它
if {![file exists work]} {
    vlib work
}

# 按 filelist.f 的顺序编译 SystemVerilog 文件
vlog -sv -mfcu -f filelist.f
