    //------------------------------------------------------------------------------
// Component    : ddr_all_cmd_fsm_seq
// Test Owner   : saketh
//
// Description  :
//   FSM-style DDR command verification sequence covering full command flow:
//   IDLE → MRS → ACT → WRITE → READ → PRECHARGE → NOP → BST + auto/precharge cases
//------------------------------------------------------------------------------

class ddr_all_cmd_fsm_seq extends uvm_sequence #(DDR_seq_item);
  `uvm_object_utils(ddr_all_cmd_fsm_seq)

  DDR_seq_item seq;
  rand bit [1:0]  target_ba;
  rand bit [13:0] target_row;
  bit [9:0] col_addr[$];
  bit [9:0] pop_addr;

  function new(string name = "ddr_all_cmd_fsm_seq");
    super.new(name);
  endfunction

  task body();

    seq = DDR_seq_item::type_id::create("seq");
    `uvm_info("SEQ", "Generating transaction", UVM_LOW)

    //Idle CMD
    start_item(seq);
    if (!seq.randomize with {cmd == IDLE;})
      `uvm_error("SEQ_IDLE","random failed")
    finish_item(seq);
    //MRS CMD
    start_item(seq);
    if (!seq.randomize with {cmd == MRS; cfg_bl==4; cfg_cl==2; cfg_bt==1;})
      `uvm_error("SEQ_MRS","random failed")
    finish_item(seq);

    //==================== 1 ====================
    $display("1...ACT>>WR>>RD>>PRE");

    if (!this.randomize())
      `uvm_error("SEQ_RAND","failed")
    //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);
    //WRITE
    start_item(seq);
    if (!seq.randomize with {cmd == WRITE; cfg_bl==4; ba==target_ba; addr[2:0]==0; auto_precharge==0; dm==0;})
      `uvm_error("SEQ_WR","random failed")
    col_addr.push_back(seq.addr);
    finish_item(seq);
    //READ
    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
      if (!seq.randomize with {cmd == READ; cfg_bl==4; ba==target_ba; addr==pop_addr; auto_precharge==0;})
        `uvm_error("SEQ_RD","random failed")
      finish_item(seq);
    end
    //PRECHARGE
    start_item(seq);
    if (!seq.randomize with {cmd == PRECHARGE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_PRE","random failed")
    finish_item(seq);

    //==================== 2 ====================
    $display("2...ACT>>WR>>RD(AP)");

    if (!this.randomize())
      `uvm_error("SEQ_RAND","failed")
    //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);
    //WRITE
    start_item(seq);
    if (!seq.randomize with {cmd == WRITE; cfg_bl==4; ba==target_ba; addr[2:0]==0; auto_precharge==0; dm==0;})
      `uvm_error("SEQ_WR","random failed")
    col_addr.push_back(seq.addr);
    finish_item(seq);

    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
      if (!seq.randomize with {cmd == READ; cfg_bl==4; ba==target_ba; addr==pop_addr; auto_precharge==1;})
        `uvm_error("SEQ_RD","random failed")
      finish_item(seq);
    end

    //==================== 3 ====================
    $display("3...ACT>>WR>>PRE");

     //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);

    //WRITE
    start_item(seq);
    if (!seq.randomize with {cmd == WRITE; cfg_bl==4; ba==target_ba; addr[2:0]==0; auto_precharge==0; dm==0;})
      `uvm_error("SEQ_WR","random failed")
    col_addr.push_back(seq.addr);
    finish_item(seq);

     //PRECHARGE
    start_item(seq);
    if (!seq.randomize with {cmd == PRECHARGE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_PRE","random failed")
    finish_item(seq);

    //==================== 4 ====================
    $display("4...ACT>>RD>>PRE");

     //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);

    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
      if (!seq.randomize with {cmd == READ; cfg_bl==4; ba==target_ba; addr==pop_addr; auto_precharge==0;})
        `uvm_error("SEQ_RD","random failed")
      finish_item(seq);
    end

    //PRECHARGE
    start_item(seq);
    if (!seq.randomize with {cmd == PRECHARGE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_PRE","random failed")
    finish_item(seq);

    //==================== 5 ====================
    $display("5...ACT>>3WR>>PRE");

     //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);
    //WRITE
    repeat (3) begin
      start_item(seq);
      if (!seq.randomize with {cmd == WRITE; cfg_bl==4; ba==target_ba; addr[2:0]==0; auto_precharge==0; dm==0;})
        `uvm_error("SEQ_WR","random failed")
      col_addr.push_back(seq.addr);
      finish_item(seq);
    end

    start_item(seq);
    if (!seq.randomize with {cmd == PRECHARGE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_PRE","random failed")
    finish_item(seq);

    //==================== 6 ====================
    $display("6...ACT>>3RD>>PRE");

    //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);

    repeat (3) begin
      if (col_addr.size() > 0) begin
        start_item(seq);
        pop_addr = col_addr.pop_front();
        if (!seq.randomize with {cmd == READ; cfg_bl==4; ba==target_ba; addr==pop_addr; auto_precharge==0;})
          `uvm_error("SEQ_RD","random failed")
        finish_item(seq);
      end
    end

    start_item(seq);
    if (!seq.randomize with {cmd == PRECHARGE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_PRE","random failed")
    finish_item(seq);

    //==================== 7 ====================
    $display("7...ACT>>WR(AP)");

    //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);
    //WRITE
    start_item(seq);
    if (!seq.randomize with {cmd == WRITE; cfg_bl==4; ba==target_ba; addr[2:0]==0; auto_precharge==1; dm==0;})
      `uvm_error("SEQ_WR","random failed")
    col_addr.push_back(seq.addr);
    finish_item(seq);

    //==================== 8 ====================
    $display("8...ACT>>RD(AP)");

    //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);

    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
      if (!seq.randomize with {cmd == READ; cfg_bl==4; ba==target_ba; addr==pop_addr; auto_precharge==1;})
        `uvm_error("SEQ_RD","random failed")
      finish_item(seq);
    end

    //==================== 9 ====================
    $display("9...ACT>>WR>>WR(AP)");

    //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);
     //WRITE
    start_item(seq);
    if (!seq.randomize with {cmd == WRITE; cfg_bl==4; ba==target_ba; addr[2:0]==0; auto_precharge==0; dm==0;})
      `uvm_error("SEQ_WR","random failed")
    col_addr.push_back(seq.addr);
    finish_item(seq);

    start_item(seq);
    if (!seq.randomize with {cmd == WRITE; cfg_bl==4; ba==target_ba; addr[2:0]==0; auto_precharge==1; dm==0;})
      `uvm_error("SEQ_WR","random failed")
    col_addr.push_back(seq.addr);
    finish_item(seq);

    //==================== 10 ====================
    $display("10...ACT>>RD>>RD(AP)");

    //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);

    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
      if (!seq.randomize with {cmd == READ; cfg_bl==4; ba==target_ba; addr==pop_addr; auto_precharge==0;})
        `uvm_error("SEQ_RD","random failed")
      finish_item(seq);
    end

    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
      if (!seq.randomize with {cmd == READ; cfg_bl==4; ba==target_ba; addr==pop_addr; auto_precharge==1;})
        `uvm_error("SEQ_RD","random failed")
      finish_item(seq);
    end

    //==================== 11 ====================
    $display("11...ACT>>NOP>>PRE");

   //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==2'b01; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);

    repeat (3) begin
      start_item(seq);
      if (!seq.randomize with {cmd == NOP;})
        `uvm_error("SEQ_NOP","random failed")
      finish_item(seq);
    end

    start_item(seq);
    if (!seq.randomize with {cmd == PRECHARGE; ba==2'b01; addr==target_row;})
      `uvm_error("SEQ_PRE","random failed")
    finish_item(seq);

    //==================== 12 ====================
    $display("12...ACT>>WR>>RD>>BST");

     //ACTIVATE
    start_item(seq);
    if (!seq.randomize with {cmd == ACTIVATE; ba==target_ba; addr==target_row;})
      `uvm_error("SEQ_ACT","random failed")
    finish_item(seq);
    //WRITE
    start_item(seq);
    if (!seq.randomize with {cmd == WRITE; cfg_bl==4; ba==target_ba; addr[2:0]==0; auto_precharge==0; dm==0;})
      `uvm_error("SEQ_WR","random failed")
    col_addr.push_back(seq.addr);
    finish_item(seq);

    if (col_addr.size() > 0) begin
      start_item(seq);
      pop_addr = col_addr.pop_front();
      if (!seq.randomize with {cmd == READ; cfg_bl==4; ba==target_ba; addr==pop_addr; bst_mode==1; auto_precharge==0;})
        `uvm_error("SEQ_RD","random failed")
      finish_item(seq);
    end

    repeat (1) begin
      start_item(seq);
      if (!seq.randomize with {cmd == NOP;})
        `uvm_error("SEQ_NOP","random failed")
      finish_item(seq);
    end
    //BST
    start_item(seq);
    if (!seq.randomize with {cmd == BST;})
      `uvm_error("SEQ_BST","random failed")
    finish_item(seq);

  endtask

endclass
