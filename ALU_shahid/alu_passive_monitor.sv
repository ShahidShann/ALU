class alu_passive_monitor extends uvm_monitor;
  `uvm_component_utils(alu_passive_monitor)
  function new(string name = "alu_passive_monitor", uvm_component parent);
    super.new(name,parent);
  endfunction
  virtual intf vif;
  alu_sequence_item txn;
  uvm_analysis_port#(alu_sequence_item) alu_analysis_port;
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    txn = alu_sequence_item::type_id::create("txn");
    alu_analysis_port = new("alu_analysis_port",this);
    if(!(uvm_config_db#(virtual intf)::get(this,"","vif",vif))) begin
      `uvm_fatal("Monitor","Unable to get the interface")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
     super.run_phase(phase);
    forever begin
      @(posedge vif.clk);
      if(vif.ce)begin
        if(vif.rst)begin
          txn.res= vif.res;
          txn.cout= vif.cout;
          txn.oflow= vif.oflow;
          txn.g= vif.g;
          txn.e= vif.e;
          txn.l= vif.l;
          txn.err= vif.err;
         end
        else if(vif.model)begin
          if(vif.inp_valid==2'b01)begin
            case(vif.cmd)
              4'b0100:begin
                txn.res= vif.res;
              end
              4'b0101:begin
                txn.res=vif.res;
              end
            endcase
         end
         else if(vif.inp_valid==2'b10)begin
            case(vif.cmd)
              4'b0110:begin
                txn.res= vif.res;
              end
              4'b0111:begin
                txn.res= vif.res;
              end
            endcase
          end
        else if(vif.inp_valid==2'b11)begin
          case(vif.cmd)
        4'b0000: begin
             txn.res = vif.res;
        end
        4'b0001: begin
             txn.res = vif.res;
        end
        4'b0010: begin
             txn.res = vif.res;
        end
        4'b0011: begin
             txn.res = vif.res;
        end
        4'b0100: begin
             txn.res = vif.res;
        end
        4'b0101: begin
             txn.res = vif.res;
        end
        4'b0110: begin
             txn.res = vif.res;
        end
        4'b0111: begin
             txn.res = vif.res;
        end
        4'b1000: begin
             txn.res = vif.res;
        end
        4'b1001: begin
             txn.res = vif.res;
        end
        4'b1010: begin
             txn.res = vif.res;
        end
        default: begin
             txn.res = vif.res;
             txn.cout = vif.cout;
             txn.oflow = vif.oflow;
             txn.g = vif.g;
             txn.e = vif.e;
             txn.l = vif.l;
             txn.err = vif.err;
        end
      endcase
    end
    end
   end
     else begin
       txn.res= vif.res;
       txn.cout= vif.cout;
       txn.oflow= vif.oflow;
       txn.g= vif.g;
       txn.e= vif.e;
       txn.l= vif.l;
       txn.err=vif.err;
     end
    alu_analysis_port.write(txn);
end
  endtask
endclass

