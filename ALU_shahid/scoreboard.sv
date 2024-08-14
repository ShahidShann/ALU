//`uvm_analysis_imp_decl(_1)
//`uvm_analysis_imp_decl(_2)
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  uvm_tlm_analysis_fifo #(alu_sequence_item)act_port;
  uvm_tlm_analysis_fifo #(alu_sequence_item)pas_port;
  alu_sequence_item txn;
  //alu_sequence_item rxn;
  virtual intf vif;

  bit [DW:0] res;
  bit oflow;
  bit cout;
  bit g;
  bit l;
  bit e;
  bit err;

  function new(string name="scoreboard",uvm_component parent=null);
    super.new(name,parent);
    act_port=new("act_port",this);
    pas_port=new("pas_port",this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    txn=alu_sequence_item::type_id::create("txn");
    //rxn=alu_sequence_item::type_id::create("rxn");
    if(!(uvm_config_db#(virtual intf)::get(this,"","vif",vif)))
      `uvm_fatal(get_type_name(),"Failed to get virtual intf in scoreboard")
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      act_port.get(txn);
      pas_port.get(txn);
      check(txn);
      check2(txn);
    end
  endtask

  task check(alu_sequence_item txn);
    @(posedge(vif.clk))begin
      if(vif.rst)begin
        txn.opa <=0;
        txn.opb <=0;
      end
    end
      
    @(posedge(vif.clk))begin
      if(txn.ce)begin
        if(vif.rst)begin
          txn.res='bz;
          txn.cout='bz;
          txn.oflow='bz;
          txn.g='bz;
          txn.e='bz;
          txn.l='bz;
          txn.err='bz;
        end
        else if(txn.mode)begin                //Arithmetic as mode=1
          if(txn.inp_valid==2'b01)begin
            case(txn.cmd)
              4'b0100:begin
                txn.opa=txn.opa+1;
                txn.res=txn.opa;
              end
              4'b0101:begin
                txn.opa=txn.opa-1;
                txn.res=txn.opa;
              end
            endcase
            end
          else if(txn.inp_valid==2'b10)begin
            case(txn.cmd)
              4'b0110:begin
                txn.opb=txn.opb+1;
                txn.res=txn.opb;
              end
              4'b0111:begin
                txn.opb=txn.opb-1;
                txn.res=txn.opb;
              end
            endcase
          end
          else if(txn.inp_valid==2'b11)begin
            case(txn.cmd)
              4'b0000:begin
                txn.res=txn.opa+txn.opb;
                txn.cout=txn.res[8]?1:0;
              end

              4'b0001:begin
                txn.res=txn.opa-txn.opb;
                txn.oflow=(txn.opa<txn.opb)?1:0;
              end
            
              4'b0010:begin
                txn.res=txn.opa+txn.opb+txn.cin;
                txn.cout=txn.res[8]?1:0;
              end

              4'b0011:begin
                txn.oflow=(txn.opa<txn.opb)?1:0;
                txn.res=txn.opa-txn.opb-txn.cin;
              end

              4'b1000:begin
                txn.res='bz;
                if(txn.opa==txn.opb)begin
                  txn.e=1;
                  txn.g='bz;
                  txn.l='bz;
                end
                else if(txn.opa>txn.opb)begin
                  txn.e='bz;
                  txn.g=1;
                  txn.l='bz;
                end
                else begin
                  txn.e='bz;
                  txn.g='bz;
                  txn.l=1;
                end
              end

              4'b1001:begin
                txn.opa<= txn.opb+1;
                txn.opb<= txn.opb+1;
                txn.res<=txn.opa * txn.opb;
              end

              4'b1010:begin
                txn.opa<= txn.opb <<1;
                txn.res<=txn.opa - txn.opb;
              end

              default:begin
                txn.res='bz;
                txn.cout='bz;
                txn.oflow='bz;
                txn.g='bz;
                txn.e='bz;
                txn.l='bz;
                txn.err='bz;
             end
           endcase
          end
          else begin
            txn.res='bz;
            txn.cout='bz;
            txn.oflow='bz;
            txn.g='bz;
            txn.e='bz;
            txn.l='bz;
            txn.err='bz;
          end
      end
      else begin             //tx.mode=0 so logic operations
        txn.res='bz;
        txn.cout='bz;
        txn.oflow='bz;
        txn.g='bz;
        txn.e='bz;
        txn.l='bz;
        txn.err='bz;

        if(txn.inp_valid==2'b11)begin
          case(txn.cmd)
            4'b0000:txn.res={1'b0,txn.opa & txn.opb};
            4'b0001:txn.res={1'b0,~(txn.opa&txn.opb)};  // CMD_tmp = 0001: NAND
            4'b0010:txn.res={1'b0,txn.opa&&txn.opb};     // CMD_tmp = 0010: OR
 	          4'b0011:txn.res={1'b0,~(txn.opa|txn.opb)};  // CMD_tmp = 0011: NOR
            4'b0100:txn.res={1'b0,txn.opa^txn.opb};     // CMD_tmp = 0100: XOR
            4'b0101:txn.res={1'b0,~(txn.opa^txn.opb)};  // CMD_tmp = 0101: XNOR
            4'b1100:begin   //ROL_A_B
              if(txn.opb[0])
                txn.opa = {txn.opa[6:0], txn.opa[7]};
               else
                 txn.opa = txn.opa;
 
               if(txn.opb[1])
                 txn.opb =  {txn.opa[5:0], txn.opa[7:6]}; 
               else
                 txn.opb= txn.opa;
 
               if(txn.opb[2])
                 txn.res =  {txn.opb[3:0], txn.opb[7:4]} ;
               else
                 txn.res = txn.opb;
 
               if(txn.opb[4] | txn.opb[5] | txn.opb[6] | txn.opb[7])
                 txn.err=1'b1;
             end
             4'b1101:begin             // CMD_tmp = 1101: ROR_A_B 
               if(txn.opb[0])
                 txn.opa = {txn.opa[0], txn.opa[7:1]};
               else
                 txn.opa = txn.opa;
               if(txn.opb[1])
                 txn.opb =  {txn.opa[1:0], txn.opa[7:2]}; 
               else
                 txn.opb= txn.opa;
               if(txn.opb[2])
                 txn.res =  {txn.opb[3:0], txn.opb[7:4]} ;
               else
                 txn.res = txn.opb;
               if(txn.opb[4] | txn.opb[5] | txn.opb[6] | txn.opb[7])
                 txn.err=1'b0;
          end
        endcase
      end
        else if(txn.inp_valid==2'b01)begin
          case(txn.cmd)
            4'b1000:txn.res={1'b0,txn.opa>>1};      // CMD_tmp = 1000: SHR1_A 
            4'b1001:txn.res={1'b0,txn.opa<<1};      // CMD_tmp = 1001: SHL1_A
          endcase
        end
        else if(txn.inp_valid==2'b10)begin
          case(txn.cmd)
            4'b1000:txn.res={1'b0,txn.opb>>1};      // CMD_tmp = 1000: SHR1_B 
            4'b1001:txn.res={1'b0,txn.opb<<1};      // CMD_tmp = 1001: SHL1_B
          endcase
        end
        else begin
          txn.res='bz;
          txn.cout='bz;
          txn.oflow='bz;
          txn.g='bz;
          txn.e='bz;
          txn.l='bz;
          txn.err='bz;
        end
      end

    end                //tx.ce=1 is ending here
      else begin
        txn.opa<=0;
        txn.opb<=0;
      end
    end

  endtask

  task check2(alu_sequence_item txn);
    res=txn.res;
    oflow=txn.oflow;
    cout=txn.cout;
    g=txn.g;
    l=txn.l;
    e=txn.e;
    err=txn.err;
  endtask

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if(txn.res==res)
      `uvm_info(get_type_name(),"result matched",UVM_NONE)
      else
      `uvm_info(get_type_name(),$sformatf("Fail matched txn.res=%0d,res=%0d",txn.res,res),UVM_NONE)

  endfunction
endclass
