class alu_env extends uvm_env;
  `uvm_component_utils(alu_env)

  function new(string name="alu_env",uvm_component parent=null);
    super.new(name,parent);
  endfunction

  alu_active_agent a1;
  alu_passive_agent a2;
  scoreboard sb;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a1=alu_active_agent::type_id::create("a1");
    a2=alu_passive_agent::type_id::create("a2");
    sb=scoreboard::type_id::create("sb");
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a1.mon_h.alu_analysis_port.connect(sb.act_port);
    a2.mon_pass_h.alu_analysis_port.connect(sb.pas_port);
  endfunction
endclass



