# ==========================================
# Default Compile/Run Switches
# ==========================================

set comp_opts ""
set run_opts ""
# ==========================================
# Test Specific Switches
# ==========================================

if {$testname == "ddr_timing_error_test"} {

  set comp_opts "+define+INJECTING_TIMING_ERROR"
  set run_opts "+ERR_TO_WARN"

} elseif {$testname == "ddr_mul_wr_intlv_bl8_100_X4_test"} {

    set comp_opts "+define+DDR_X4"

} elseif {$testname == "ddr_mul_wr_intlv_bl8_100_X8_test"} {

    set comp_opts "+define+DDR_X8"

} elseif {$testname == "ddr_mul_wr_intlv_bl8_100_X16_test"} {

    set comp_opts "+define+DDR_X16"

} elseif {$testname == "ddr_mul_wr_intlv_bl4_100_X4_test"} {

    set comp_opts "+define+DDR_X4"

} elseif {$testname == "ddr_mul_wr_intlv_bl4_100_X8_test"} {

    set comp_opts "+define+DDR_X8"

} elseif {$testname == "ddr_mul_wr_intlv_bl4_100_X16_test"} {

    set comp_opts "+define+DDR_X16"

} elseif {$testname == "ddr_mul_wr_seq_bl8_100_X4_test"} {

    set comp_opts "+define+DDR_X4"

} elseif {$testname == "ddr_mul_wr_seq_bl8_100_X8_test"} {

    set comp_opts "+define+DDR_X8"

} elseif {$testname == "ddr_mul_wr_seq_bl8_100_X16_test"} {

    set comp_opts "+define+DDR_X16"

} elseif {$testname == "ddr_mul_wr_seq_bl4_100_X4_test"} {

    set comp_opts "+define+DDR_X4"

} elseif {$testname == "ddr_mul_wr_seq_bl4_100_X8_test"} {

    set comp_opts "+define+DDR_X8"

} elseif {$testname == "ddr_mul_wr_seq_bl4_100_X16_test"} {

    set comp_opts "+define+DDR_X16"

}

# ==========================================
# Valid Tests
# ==========================================
transcript quietly
set valid_tests {
    ddr_wr_sanity_seq_bl2_100_test
    ddr_wr_sanity_intlv_bl2_100_test
    ddr_wr_basic_seq_bl4_100_test
    ddr_wr_basic_intlv_bl4_100_test
    ddr_wr_basic_seq_bl8_100_test
    ddr_wr_basic_intlv_bl8_100_test
    ddr_wr_pre_seq_bl4_100_test
    ddr_wr_pre_intlv_bl4_100_test
    ddr_wr_pre_seq_bl8_100_test
    ddr_wr_pre_intlv_bl8_100_test
    ddr_wr_ap_seq_bl4_100_test
    ddr_wr_ap_intlv_bl4_100_test
    ddr_w_ap_intlv_bl4_100_test
    ddr_w_ap_seq_bl8_100_test
    ddr_w_ap_intlv_bl8_100_test
    ddr_wr_pd_seq_bl4_100_test
    ddr_wr_pd_intlv_bl4_100_test
    ddr_wr_pd_seq_bl8_100_test
    ddr_wr_pd_intlv_bl8_100_test
    ddr_write_dm_seq_bl4_100_test
    ddr_write_dm_intlv_bl4_100_test
    ddr_write_dm_intlv_bl8_100_test
    ddr_wr_bst_seq_bl4_100_test
    ddr_wr_bst_intlv_bl4_100_test
    ddr_wr_bst_seq_bl8_100_test
    ddr_mul_wr_intlv_bl4_100_X16_test
    ddr_mul_wr_intlv_bl4_100_X8_test
    ddr_mul_wr_intlv_bl4_100_X4_test
    ddr_mul_wr_seq_bl8_100_X16_test
    ddr_mul_wr_seq_bl8_100_X8_test
    ddr_mul_wr_seq_bl8_100_X4_test
    ddr_mul_wr_seq_bl4_100_X16_test
    ddr_mul_wr_seq_bl4_100_X8_test
    ddr_mul_wr_seq_bl4_100_X4_test
    ddr_mul_wr_intlv_bl8_100_X16_test
    ddr_mul_wr_intlv_bl8_100_X8_test
    ddr_mul_wr_intlv_bl8_100_X4_test

    ddr_wr_bst_intlv_bl8_100_test
    ddr_all_cmd_fsm_test
    ddr_act_2_time_no_pre_btwn_test
    ddr_write_dm_seq_bl8_100_test

    ddr_rd_without_wr_bl2_100_test
    ddr_wr_without_act_err_test
    ddr_wr_without_pre_test
    ddr_wr_auto_pre_bfr_data_cmp_test

    ddr_wr_ovr_wr_data_test
    ddr_mul_wr_seq_bl4_100_X16_test
    ddr_wr_ap_seq_bl8_100_test
    ddr_wr_ap_intlv_bl8_100_test
    ddr_w_ap_seq_bl4_100_test
    ddr_write_dm_intlv_bl8_100_test


   ddr_timing_error_test
   ddr_act4_wr_pre_data_test
}
# ==========================================
# Check whether test is valid
# ==========================================

if {[lsearch $valid_tests $testname] == -1} {
 

    puts "\033\[31m"

 

    puts ""
    puts "================================="
    puts "ERROR : INVALID TESTNAME"
    puts "================================="
    puts ""

 

    puts "Given Test : $testname"
    puts ""

 

    puts "\033\[0m"

 

    quit -f
}
# ==========================================
# Print Switches
# ==========================================

puts ""
puts "================================="
puts "Running Test      : $testname"
puts "Compile Switches : $comp_opts"
puts "Run Switches     : $run_opts"
puts "================================="

# ==========================================
# Log/Wave files
# ==========================================
file mkdir sim/$testname
set logfile "./sim/$testname/${testname}.log"
set wavefile "./sim/$testname/${testname}.wlf"
set qwavefile "./sim/$testname/qwave.db"
set complog "./sim/$testname/comp.log"

# ==========================================
# Library
# ==========================================

vlib work
vmap work work

# ==========================================
# Compile and checks whether compile is passed or not
# ==========================================

   set comp_status [catch {
    eval vlog -work work -sv \
        ./Basic_DDR_RTL/ddr_pkg.sv \
        ./Basic_DDR_RTL/ddr_command_decoder.sv \
        ./Basic_DDR_RTL/ddr_device_with_dqs.sv \
        ./Basic_DDR_RTL/ddr_mode_register.sv \
        DDR_package.sv \
        DDR_interface.sv \
        DDR_top.sv \
        $comp_opts \
        -l $complog
} comp_result]

if {$comp_status != 0} {

    puts ""
    puts "================================="
    puts "     COMPILATION FAILED"
    puts "================================="
    puts "Compile Log : [file normalize $complog]"
    puts "================================="

    quit -f
}

set fp [open $complog a]

puts $fp ""
puts $fp "================================="
puts $fp "COMPILE PASSED"
puts $fp "Time : [clock format [clock seconds]]"
puts $fp "================================="

close $fp
# ==========================================
# Simulation
# ==========================================

eval vsim -debugDB -voptargs=+acc work.DDR_top +UVM_TESTNAME=$testname +UVM_VERBOSITY=UVM_LOW $run_opts -l $logfile -qwavedb=+wavefile=$qwavefile
# ==========================================
# Logging
# ==========================================

add log -r /DDR_top/*
add wave -r /DDR_top/*

# ==========================================
# Prevent auto exit
# ==========================================

onfinish stop

# ==========================================
# Run Simulation
# ==========================================

run -all

after 1000

# ==========================================
# Read logfile
# ==========================================

set fp [open $logfile r]
set log_data [read $fp]
close $fp

# ==========================================
# PASS / FAIL
# ==========================================

if {[regexp {UVM_ERROR :\s+[1-9]} $log_data] || \
    [regexp {UVM_FATAL :\s+[1-9]} $log_data]} {

    puts "\033\[31m"
    puts "================================="
    puts "         TEST FAILED"
    puts "================================="
    puts "\033\[0m"

    puts ""
    puts "Log File  : [file normalize $logfile]"
    puts "Wave File : [file normalize $qwavefile]"
    puts ""

} else {

    puts ""
    puts "Log File  : [file normalize $logfile]"
    puts "Wave File : [file normalize $qwavefile]"
    puts ""
    
    puts "\033\[32m"
    puts "================================="
    puts "         TEST PASSED"
    puts "================================="
    puts "\033\[0m"

} 
quit -f

