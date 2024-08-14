class alu_active_agent extends uvm_agent;
 
  `uvm_component_utils(alu_active_agent)

  function new(string name="alu_active_agent",uvm_component parent);

    super.new(name,parent);

  endfunction

  alu_sequencer seqr_h;

  alu_driver    drv_h;

  alu_active_monitor   mon_h;

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    drv_h    = alu_driver::type_id::create("driver_h",this);

    seqr_h = alu_sequencer::type_id::create("sequencer_h",this);

    mon_h   = alu_active_monitor::type_id::create("monitor_h",this);

  endfunction

  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    drv_h.seq_item_port.connect(seqr_h.seq_item_export);

  endfunction

 
endclass
 
 
