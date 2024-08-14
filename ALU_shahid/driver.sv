class alu_driver extends uvm_driver #(alu_sequence_item);
  `uvm_component_utils(alu_driver)

  function new(string name="alu_driver",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual interface intf vif;
  alu_sequence_item txn;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    txn=alu_sequence_item::type_id::create("txn");
    if(!(uvm_config_db#(virtual intf)::get(this,"","vif",vif))) begin
      `uvm_fatal("driver","unable to get interface")
    end
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(txn);
      if(txn.ce)begin
        if(vif.rst)
          check_rst();
          else
            drive2dut();
      end
      seq_item_port.item_done();    
    end
  endtask

  task check_rst();
    vif.ce        <= 0;
    vif.opa       <= 0;
    vif.opb       <= 0;
    vif.cmd       <= 0;
    vif.mode      <= 0;
    vif.cin       <= 0;
    vif.inp_valid <= 0;
  endtask
 
  task drive2dut();
    @(negedge (vif.clk))begin
       vif.ce        <= txn.ce;
       vif.opa       <= txn.opa;
       vif.opb       <= txn.opb;
       vif.cmd       <= txn.cmd;
       vif.mode      <= txn.mode;
       vif.cin       <= txn.cin;
       vif.inp_valid <= txn.inp_valid;
     end
     `uvm_info(get_type_name(),$sformatf("opa=%0d,opb=%0d,cmd=%0d,mode=%0d,cin=%0d,inp_valid=%0d",txn.opa,txn.opb,txn.cmd,txn.mode,txn.cin,txn.inp_valid),UVM_NONE)
  endtask
 
endclass
