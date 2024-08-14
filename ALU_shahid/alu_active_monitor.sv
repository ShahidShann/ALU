class alu_active_monitor extends uvm_monitor;
  `uvm_component_utils(alu_active_monitor)
 
  function new(string name = "alu_active_monitor", uvm_component parent=null);
    super.new(name,parent);
  endfunction
 
  virtual intf vif;
  alu_sequence_item txn;
  uvm_analysis_port#(alu_sequence_item) alu_analysis_port;
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    alu_analysis_port = new("alu_analysis_port",this);
    if(!(uvm_config_db#(virtual intf)::get(this,"","vif",vif))) begin
      `uvm_fatal("Monitor","Unable to get the interface")
    end
  endfunction
 
  virtual task run_phase(uvm_phase phase);
    txn = alu_sequence_item::type_id::create("txn");
    forever begin
      @(posedge(vif.clk));
      txn.opa = vif.opa;
      txn.opb = vif.opb;
      txn.cmd = vif.cmd;
      txn.mode = vif.mode;
      txn.cin = vif.cin;
      txn.inp_valid = vif.inp_valid;
    end
    alu_analysis_port.write(txn);
  endtask
 
endclass
