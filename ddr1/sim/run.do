vlib work
vmap work work
vlog -work work  -sv ../config/DDR_package.sv ../top/DDR_interface.sv ../top/DDR_top.sv 
#vlog -sv +incdir+ DDR_package.sv
#vlog -sv DDR_interface.sv
#vlog -sv DDR_top.sv
set infile [open "ddr_sanity_seq_bl2_100_test .log" w+]
vsim -c DDR_top +UVM_TESTNAME=ddr_wr_sanity_seq_bl2_100_test  +UVM_VERBOSITY=UVM_LOW -l $infile
add log -r /DDR_top/*
add wave -r /DDR_top/*
run -all
