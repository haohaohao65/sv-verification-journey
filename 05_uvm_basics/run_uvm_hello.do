# 在 ModelSim Transcript 中执行：
# do E:/IC_Verification/sv-verification-journey/05_uvm_basics/run_uvm_hello.do
# 运行构建阶段练习：
# do E:/IC_Verification/sv-verification-journey/05_uvm_basics/run_uvm_hello.do 06_build_phase.sv tb_build_phase
# 如已有其他仿真，先执行 quit -sim，再运行此脚本。
# 不传参数时运行 05_uvm_hello.sv；两个参数分别指定练习文件和顶层模块名。
# 使用本机 UVM 1.2 源码，关闭当前基础练习不需要的 DPI（与 C 代码连接的接口）。
# 编译库和 modelsim.ini 放在临时目录，不改动安装目录的配置。

onerror {abort}

# ModelSim 的 do 命令不把当前宏文件路径交给 Tcl 的 info script。
# 这里明确指定本机练习目录，避免错误地取到 ModelSim 启动脚本的路径。
set uvm_lesson_dir E:/IC_Verification/sv-verification-journey/05_uvm_basics
set uvm_lesson_file 05_uvm_hello.sv
set uvm_top_name tb_uvm_hello
if {[info exists 1]} {
    set uvm_lesson_file $1
}
if {[info exists 2]} {
    set uvm_top_name $2
}
set uvm_install_dir E:/modeltech64_2020.4
set uvm_src_dir [file join $uvm_install_dir verilog_src uvm-1.2 src]
set uvm_build_dir [file join $env(TEMP) uvm_basics_hello_[pid]]
file mkdir $uvm_build_dir
cd $uvm_build_dir

if {![file exists modelsim.ini]} {
    vmap -c
}
if {![file exists work]} {
    vlib work
}
if {![file exists uvm12]} {
    vlib uvm12
}
vmap work work
vmap mtiUvm uvm12

# 源码编译时关闭可选 DPI 导入；加载时关闭 DPI 导出包装生成。
# 这是针对本机缺少 C/C++ 编译器的基础练习配置。
vlog -sv +define+UVM_NO_DPI +incdir+$uvm_src_dir -work mtiUvm [file join $uvm_src_dir uvm_pkg.sv]
# 练习可能 include 前面写好的类，加入练习目录供查找文件。
vlog -sv -L mtiUvm +define+UVM_NO_DPI +incdir+$uvm_src_dir +incdir+$uvm_lesson_dir -work work [file join $uvm_lesson_dir $uvm_lesson_file]
vsim -onfinish stop -nodpiexports -L mtiUvm work.$uvm_top_name
run -all
# 保留已加载的仿真供查看。仿真加载期间不能执行 cd。
# 再次运行时先 quit -sim，然后使用上面的绝对路径 do 命令。
