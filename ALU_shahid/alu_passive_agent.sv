class alu_passive_agent extends uvm_agent;
 `uvm_component_utils(alu_passive_agent)

  function new(string name="alu_passive_agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  alu_passive_monitor   mon_pass_h;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
       mon_pass_h   = alu_passive_monitor::type_id::create("monitor_h",this);
  endfunction

 
 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction

 
endclass
