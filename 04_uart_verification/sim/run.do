# ModelSim Tcl 脚本，不是 SystemVerilog：从编译到打开波形的一次测试入口。
# 在 sim 目录执行；切换已加载测试时，先在 Transcript 执行 quit -sim。
# Usage: do run.do normal
# With no argument, run the normal test.
# set 定义变量；info exists 1 检查是否传入第一个脚本参数；$1 读取该参数。
set uart_test_name normal
if {[info exists 1]} {
    set uart_test_name $1
}

# 每次启动重新编译，让保存后的代码改动生效。
do compile.do

# 加载 work.tb；+TEST 交给 Generator 的 $value$plusargs 读取。
# -onfinish stop 保留窗口，+acc 保留更多信号访问能力以便查看波形。
vsim -onfinish stop -voptargs=+acc work.tb +TEST=$uart_test_name
# -r 递归添加层次信号；run -all 运行到 finish/fatal/暂停，最后缩放显示整段波形。
add wave -r /*
run -all
wave zoom full
