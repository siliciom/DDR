interface DDR_interface(input bit ck_t,input bit ck_c);

//   CLOCK ENABLE SIGNAL
  logic cke;
//   COMMAND SIGNALS
  logic cs;
  logic ras;
  logic cas;
  logic we;
//   ADDRESS SIGNALS
  logic [1:0] ba;
  logic [13:0]addr;
//   DATA SIGNALS
  logic [15:0] dq;
  logic dqs;
  logic dm;


  /*clocking ddr_drv_cb @(posedge ck_t );//or negedge ck_c);
		default input #0 output #0;

		output cke;
		output cs;
		output ras;
		output cas;
		output we;

		output ba;
		output addr;

		inout dq;
		inout dqs;
		output dm;

	endclocking


	 clocking ddr_mon_cb @(posedge ck_t or negedge ck_c);
		default input #0 output #0;

		input cke;
		input cs;
		input ras;
		input cas;
		input we;

		input ba;
		input addr;

		input dq;
		input dqs;
		input dm;

	endclocking

	modport DDR_DRV_MP (clocking ddr_drv_cb);
	modport DDR_MON_MP (clocking ddr_mon_cb);*/

  
endinterface
  
  
  
