package tb_pkg;

`include "uvm_macros.svh"
import uvm_pkg::*;
//parameter int DW=8;
//parameter int CW=4;
import globals::*;

//`include "alu_interface.sv"
`include "seq_item.sv"        
`include "sequence.sv"             
`include "alu_sequencer.sv"            
`include "driver.sv"             
`include "alu_active_monitor.sv"
`include "alu_passive_monitor.sv"
`include "alu_active_agent.sv"  
`include "alu_passive_agent.sv"
`include "scoreboard.sv"           
`include "alu_env.sv"                  
`include "test.sv"                 
//`include "top.sv"                 
 
endpackage 
