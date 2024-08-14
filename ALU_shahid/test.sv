class alu_test extends uvm_test;
  `uvm_component_utils(alu_test)
  alu_env env_h;
  alu_sequence seq_h;
  
  function new(string name="alu_test",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h = alu_env::type_id::create("env_h",this);
    seq_h = alu_sequence :: type_id::create("seq_h",this);
  endfunction

  function void end_of_elobartion_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
    
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
     seq_h.start(env_h.a1.seqr_h);
     #10;
	  phase.drop_objection(this);
  endtask
endclass
