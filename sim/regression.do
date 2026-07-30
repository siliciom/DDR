#========================================================
# CLEAN WORK LIBRARY
#========================================================
if {[file exists work]} {
    vdel -all
}

#========================================================
# To pass Regression Name from the Command Line
#========================================================
if {![info exists regression_name]} {
    set regression_name "default_regression"
}

#========================================================
# COVERAGE ENABLE/DISABLE
#========================================================
if {![info exists enable_cov]} {
    set enable_cov 0
}
 
#========================================================
# TEST LIST (Add all the Tests)
#========================================================
set test_list {

    ddr_wr_basic_seq_bl8_100_test
    ddr_mul_wr_seq_bl4_100_X16_test
    ddr_wr_ap_seq_bl8_100_test
    ddr_wr_ap_intlv_bl8_100_test
    ddr_w_ap_seq_bl4_100_test
    ddr_write_dm_intlv_bl8_100_test
    ddr_wr_without_pre_test
    ddr_wr_ovr_wr_data_test


    ddr_act4_wr_pre_data_test
    ddr_rd_without_wr_bl2_100_test
    ddr_wr_sanity_seq_bl2_100_test
    ddr_wr_basic_intlv_bl8_100_test
    ddr_mul_wr_intlv_bl4_100_X16_test
    ddr_mul_wr_intlv_bl4_100_X4_test
    ddr_mul_wr_intlv_bl4_100_X8_test
    ddr_wr_ap_seq_bl4_100_test
    ddr_w_ap_intlv_bl4_100_test
    ddr_wr_bst_seq_bl4_100_test


    ddr_wr_basic_intlv_bl4_100_test
    ddr_mul_wr_seq_bl4_100_X8_test
    ddr_mul_wr_seq_bl4_100_X4_test
    ddr_w_ap_seq_bl8_100_test
    ddr_wr_bst_intlv_bl8_100_test
    ddr_all_cmd_fsm_test
    ddr_act_2_time_no_pre_btwn_test
    ddr_write_dm_seq_bl8_100_test

    ddr_wr_sanity_intlv_bl2_100_test
    ddr_wr_ap_intlv_bl4_100_test
    ddr_mul_wr_seq_bl8_100_X16_test
    ddr_mul_wr_seq_bl8_100_X8_test
    ddr_mul_wr_seq_bl8_100_X4_test
    ddr_timing_error_test
    ddr_write_dm_seq_bl4_100_test
    ddr_wr_bst_intlv_bl4_100_test
    ddr_wr_auto_pre_bfr_data_cmp_test

   ddr_mul_wr_intlv_bl8_100_X16_test
   ddr_mul_wr_intlv_bl8_100_X8_test
   ddr_mul_wr_intlv_bl8_100_X4_test
   ddr_wr_basic_seq_bl4_100_test
   ddr_w_ap_intlv_bl8_100_test
   ddr_write_dm_intlv_bl4_100_test
   ddr_wr_bst_seq_bl8_100_test
   ddr_wr_without_act_err_test
   ddr_act4_wr_op_data_test
   ddr_wr_pd_seq_bl4_100_test
 
   

}


#========================================================
# PASS / FAIL VARIABLES
#========================================================
proc check_result {logfile testname} {

    if {![file exists $logfile]} {
        puts "FAILED : $testname (Log file not found)"
        return "FAIL"
    }

    set fh [open $logfile r]
    set content [read $fh]
    close $fh

    #--------------------------------------------------
    # Check UVM Summary
    #--------------------------------------------------
    set error_count 0
    set fatal_count 0

    if {[regexp {UVM_ERROR\s*:\s*([0-9]+)} $content -> error_count]} {
        # Found UVM_ERROR count
    }

    if {[regexp {UVM_FATAL\s*:\s*([0-9]+)} $content -> fatal_count]} {
        # Found UVM_FATAL count
    }

    if {$error_count > 0 || $fatal_count > 0} {

        puts "FAILED : $testname (UVM_ERROR=$error_count UVM_FATAL=$fatal_count)"

        return "FAIL"
    }

    puts "PASSED : $testname"

    return "PASS"
} 
#========================================================
# REGRESSION LOOP
#========================================================
set pass_count 0
set fail_count 0
set fail_list {}
 
set last_comp_opts "__NONE__" 
foreach testname $test_list {

#=========================================
# Seed Handling (Picks Random Seed)
#=========================================
set seed [expr {int(rand()*1000000)}]


# ==========================================
# Default Compile/Run Switches
# ==========================================
set comp_opts ""
set run_opts ""

# ==========================================
# Test Specific Switches (Add the tests which are having comp or run opts)
# ==========================================
if {$testname == "ddr_mul_wr_intlv_bl8_100_X4_test"} {

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


    puts "TEST      : $testname"
    puts "COMP_OPTS : $comp_opts"
    puts "RUN_OPTS  : $run_opts" 
 
 
    echo "======================================="
    echo "RUNNING TEST : $testname"
    echo "======================================="
    # UCDB FILE NAME

set test_dir "./Regression/$regression_name/$testname"
file mkdir $test_dir
set logfile "$test_dir/run.log"
set complog "$test_dir/comp.log"


#====================================================
# COMPILE
#====================================================

if {$comp_opts ne $last_comp_opts} {

    puts "================================="
    puts "COMPILING"
    puts "TEST      : $testname"
    puts "COMP_OPTS : <$comp_opts>"
    puts "================================="

    if {$enable_cov} {
        set cov_compile_opts "-cover bsectf +fcover"
    } else {
        set cov_compile_opts ""
    }

    transcript file $complog

    set comp_status [catch {

        eval vlog -work work $cov_compile_opts -sv -incr -mfcu \
        ../Design/Basic_DDR_RTL/ddr_pkg.sv \
        ../Design/Basic_DDR_RTL/ddr_command_decoder.sv \
        ../Design/Basic_DDR_RTL/ddr_device_with_dqs.sv \
        ../Design/Basic_DDR_RTL/ddr_mode_register.sv \
        ../config/DDR_package.sv \
        ../top/DDR_interface.sv \
        ../top/DDR_top.sv \
        $comp_opts

    } comp_result]

    transcript file ""

    if {$comp_status != 0} {

        puts "COMPILE FAILED : $testname"
        puts $comp_result

        incr fail_count
        lappend fail_list $testname

        continue
    }

    set last_comp_opts $comp_opts

} else {

    puts "================================="
    puts "SKIPPING COMPILE"
    puts "TEST      : $testname"
    puts "COMP_OPTS : <$comp_opts>"
    puts "================================="
}
	
if {$enable_cov} {
	set cov_dir "./coverage_reports/$regression_name"
 
file mkdir $cov_dir
set ucdb_file "$cov_dir/$testname.ucdb"
}

 
#====================================================
# SIMULATION
#====================================================

set sim_cov_opts ""

if {$enable_cov} {

    set sim_cov_opts "-coverage -cvgperinstance"

    set do_cmd \
        "coverage save -onexit $ucdb_file; run -all; quit -f"

} else {

    set do_cmd "run -all; quit -f"
}

set sim_status [catch {

    exec vsim -c \
        {*}$sim_cov_opts \
        -debugDB \
        -voptargs=+acc \
        work.DDR_top \
        +UVM_TESTNAME=$testname \
        -l $logfile \
        -sv_seed $seed \
        $run_opts \
        -do "$do_cmd"

} sim_result]

if {$sim_status != 0} {

    puts "ELAB/SIM FAILED : $testname"
    puts $sim_result

    incr fail_count
    lappend fail_list $testname

    continue
}
   #====================================================
    # CHECK PASS / FAIL
    #====================================================
    set result [check_result $logfile $testname]
 
    if {$result == "PASS"} {
        incr pass_count
    } else {
        incr fail_count
        lappend fail_list $testname
    }
 
    echo "COMPLETED : $testname"
}
 
#========================================================
# SHOW GENERATED UCDB FILES
#========================================================

if {$enable_cov} {

echo "======================================="
echo "GENERATED COVERAGE FILES"
echo "======================================="
set ucdb_files [glob -nocomplain coverage_reports/*/*.ucdb]
 
if {[llength $ucdb_files] == 0} {
    echo "❌ NO UCDB FILES FOUND"
} else {
    foreach f $ucdb_files {
        echo $f
    }
}
 
#========================================================
# MERGE COVERAGE
#========================================================
echo "======================================="
echo "MERGING COVERAGE DATABASES"
echo "======================================="
 
set ucdb_files [glob -nocomplain ./coverage_reports/$regression_name/*.ucdb]
set ucdb_files [lsearch -all -inline -not $ucdb_files "coverage_reports/*/merged_cov.ucdb"]
 
if {[llength $ucdb_files] == 0} {
    echo "❌ NO UCDB FILES TO MERGE"
} else {
set merged_ucdb "./coverage_reports/$regression_name/merged_coverage.ucdb"

eval vcover merge $merged_ucdb $ucdb_files}
 
#========================================================
# GENERATE COVERAGE REPORT
#========================================================
echo "======================================="
echo "GENERATING COVERAGE REPORT"
echo "======================================="
 
set html_dir "./covhtmlreport/$regression_name/html"

file mkdir $html_dir

vcover report \
    -details \
    -html \
    $merged_ucdb \
    -output $html_dir 
#========================================================
# FINAL REGRESSION SUMMARY
#========================================================
}
echo "======================================="
echo "        REGRESSION SUMMARY"
echo "======================================="
 
echo "TOTAL  TESTS : [llength $test_list]"
echo "PASSED TESTS : $pass_count"
echo "FAILED TESTS : $fail_count"
 
echo "======================================="
 
#========================================================
# PRINT FAILED TESTS
#========================================================
if {$fail_count > 0} {
    echo "FAILED TESTCASES:"
    foreach ft $fail_list {
        echo "   ❌ $ft"
    }
}
 
echo "======================================="
echo "REGRESSION COMPLETED"
echo "======================================="
quit -f



#======================================================================================================
#======================================================================================================

# Regression Run Command: vsim -c -do .\regression.do
# Regression Run Command with regr_name:  vsim -c -do "set regression_name march_regr; do regression.do"
# Regression Run Command with regr_name and covergae enable: vsim -c -do "set regression_name regr_cov1; set enable_cov 1; do regression.do"

# Logs Path: Regression/regression_name/test_name/run.log
# Single Coverage Path: coverage_reports/regression_name/test_name.ucdb
# Merged Coverage Path: coverage_reports/regression_name/merged_coverage.ucdb
# HTML Coverage Path: covhtmlreport\regression_name/html

#======================================================================================================
#======================================================================================================


