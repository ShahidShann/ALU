import globals::*;
interface intf(input clk,input rst);
  logic [1:0] inp_valid;
  logic mode;
  logic [CW-1:0] cmd;
  logic ce;
  logic [DW-1:0] opa;
  logic [DW-1:0] opb;
  logic cin;
  logic [DW:0] res;
  logic oflow;
  logic cout;
  logic g;
  logic l;
  logic e;
  logic err;
endinterface
