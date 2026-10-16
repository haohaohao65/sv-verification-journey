onerror {quit -f -code 1}

# Temporary external checks; no stimulus is added to the learner's testbench.
proc check_reset_state {time_label expected_reset} {
    set reset_value [examine -radix binary sim:/tb_top/vif/reset]
    set empty_value [examine -radix binary sim:/tb_top/vif/empty]
    set full_value [examine -radix binary sim:/tb_top/vif/full]
    set dout_value [examine -radix unsigned sim:/tb_top/vif/dout]
    set write_value [examine -radix binary sim:/tb_top/vif/w_enb]
    set read_value [examine -radix binary sim:/tb_top/vif/r_enb]
    puts "CHECK time=$time_label reset=$reset_value empty=$empty_value full=$full_value dout=$dout_value w=$write_value r=$read_value"
    if {$reset_value ne $expected_reset || $empty_value ne "1" || $full_value ne "0" || $dout_value ne "0" || $write_value ne "0" || $read_value ne "0"} {
        puts "TOP_RESET_SMOKE_FAIL"
        quit -f -code 1
    }
}

# Check away from clock edges, after their scheduled updates have completed.
run 1 ns
check_reset_state 1ns 1
run 15 ns
check_reset_state 16ns 1
run 5 ns
check_reset_state 21ns 0
run 10 ns
check_reset_state 31ns 0
run -all
puts "TOP_RESET_SMOKE_PASS"
quit -f -code 0
