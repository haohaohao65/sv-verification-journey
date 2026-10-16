# Batch compile/run of the FIFO UVM test; run from the project directory.
# Optional first argument: absolute path to the FIFO project directory.
# Optional second argument: test name (empty uses tb_top's default).
# Optional third argument: compile, run, or both (default).
# Optional fourth argument: positive SystemVerilog random seed.
# Optional fifth argument: functional coverage report output path.
# Use run_regression.ps1 for functional verdicts and failure exit codes.
onerror {quit -f -code 1}

set fifo_project_dir [file normalize [pwd]]
if {[info exists 1]} {
    set fifo_project_dir [file normalize [set 1]]
}
if {![file exists [file join $fifo_project_dir tb tb_top.sv]]} {
    puts "Run from the 06_uvm_fifo_verification directory, or pass its absolute path."
    quit -f -code 1
}
set fifo_test_name ""
if {[info exists 2]} {set fifo_test_name [set 2]}
if {$fifo_test_name ne "" && ![regexp {^[A-Za-z_][A-Za-z0-9_]*$} $fifo_test_name]} {
    puts "Invalid test name: $fifo_test_name"
    quit -f -code 1
}
set fifo_mode both
if {[info exists 3]} {set fifo_mode [set 3]}
if {[lsearch -exact {compile run both} $fifo_mode] < 0} {
    puts "Mode must be compile, run, or both."
    quit -f -code 1
}
set fifo_seed ""
if {[info exists 4]} {set fifo_seed [set 4]}
if {$fifo_seed ne "" && (![string is integer -strict $fifo_seed] || $fifo_seed < 1 || $fifo_seed > 2147483647)} {
    puts "Seed must be an integer from 1 to 2147483647."
    quit -f -code 1
}
set fifo_coverage_report ""
if {[info exists 5]} {set fifo_coverage_report [file normalize [set 5]]}
set fifo_uvm_src E:/modeltech64_2020.4/verilog_src/uvm-1.2/src
set fifo_build_dir [file join $fifo_project_dir sim build uvm_start]
file mkdir $fifo_build_dir
cd $fifo_build_dir

if {![file exists modelsim.ini]} {vmap -c}
if {![file exists work]} {vlib work}
if {![file exists uvm12]} {vlib uvm12}
vmap work work
vmap mtiUvm uvm12

if {$fifo_mode ne "run"} {
# Compile UVM 1.2 explicitly; the installation default maps mtiUvm to 1.1d.
# Match tb_top's time unit for time arguments passed to UVM.
vlog -sv -timescale 1ns/1ps +define+UVM_NO_DPI +incdir+$fifo_uvm_src -work mtiUvm [file join $fifo_uvm_src uvm_pkg.sv]
vlog -sv -L mtiUvm +define+UVM_NO_DPI +incdir+$fifo_uvm_src +incdir+[file join $fifo_project_dir tb] -work work \
    [file join $fifo_project_dir tb fifo_if.sv] \
    [file join $fifo_project_dir dut sync_fifo.v] \
    [file join $fifo_project_dir tb fifo_tb_pkg.sv] \
    [file join $fifo_project_dir tb tb_top.sv]
echo FIFO_COMPILE_OK
}

if {$fifo_mode eq "compile"} {quit -f -code 0}

set fifo_vsim_command [list vsim -onfinish stop -nodpiexports -L mtiUvm]
if {$fifo_seed ne ""} {
    lappend fifo_vsim_command -sv_seed $fifo_seed
    echo FIFO_RANDOM_SEED=$fifo_seed
}
lappend fifo_vsim_command work.tb_top
if {$fifo_test_name ne ""} {lappend fifo_vsim_command +TESTNAME=$fifo_test_name}
eval $fifo_vsim_command
run -all
if {$fifo_coverage_report ne ""} {
    coverage report -cvg -details -output $fifo_coverage_report
}
# The PowerShell entry point checks the completed transcript, including fatal
# reports and missing FINAL PASS, before returning a functional exit code.
quit -f -code 0
