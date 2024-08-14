`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import tb_pkg::*;
//`include "alu_interface.sv"
import globals::*;

module top();

  bit pclk=0;
  bit prst;
  always #5 pclk=~pclk;

  initial begin
    $display("Top");
  end

  initial begin
    prst =1;
    #5 prst =0;
  end


  intf vif(.clk(pckl),.rst(prst));

  ALU_DESIGN dut(.OPA (vif.opa),
          .OPB(vif.opb),
          .CMD(vif.cmd),
          .MODE(vif.mode),
          .CIN(vif.cin),
          .CE(vif.ce),
          .INP_VALID(vif.inp_valid),
          .RES(vif.res),
          .COUT(vif.cout),
          .OFLOW(vif.oflow),
          .G(vif.g),
          .L(vif.l),
          .E(vif.e),
          .ERR(vif.err));
 
 
  initial begin
    uvm_config_db #(virtual intf)::set(null,"uvm_test_top.*","vif",vif);
  end
 
  initial begin
    run_test("alu_test");
  end
endmodule
