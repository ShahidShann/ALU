module ALU_DESIGN #(parameter DW = 8, CW = 4)(INP_VALID,OPA,OPB,CIN,CLK,RST,CMD,CE,MODE,COUT,OFLOW,RES,G,E,L,ERR);

//changes by MP :
//1. first capture the CMD,  inputs A , B wrt to INP_VALID signal
//2. added arthimatic opertaion 9,10 - 3 cycle operation
 
//Input output port declaration
  input [DW-1:0] OPA,OPB;
  input CLK,RST,CE,MODE,CIN;
  input [CW-1:0] CMD;
  input [1:0] INP_VALID;
  output reg [DW:0] RES = 9'bz;
  output reg COUT = 1'bz;
  output reg OFLOW = 1'bz;
  output reg G = 1'bz;
  output reg E = 1'bz;
  output reg L = 1'bz;
  output reg ERR = 1'bz;
 
//Temporary register declaration
  reg [DW-1:0] OPA_1, OPB_1;
  reg [DW-1:0] oprd1, oprd2;
  reg [3:0] CMD_tmp;
 reg [DW-1:0] AU_out_tmp1,AU_out_tmp2 ;
  always @ (posedge CLK) begin
      if(RST) begin
        oprd1<=0;
        oprd2<=0;
        CMD_tmp<=0;
      end
      else if (INP_VALID==2'b01)  begin    
        oprd1<=OPA;
        CMD_tmp<=CMD;
      end
      else if (INP_VALID==2'b10)  begin    
        oprd2<=OPB;
        CMD_tmp<=CMD;
      end
      else if (INP_VALID==2'b11)  begin    
        oprd1<=OPA;
        oprd2<=OPB;
        CMD_tmp<=CMD;
      end
      else begin    
        oprd1<=0;
        oprd2<=0;
        CMD_tmp<=0;
      end
    end 



    always@(posedge CLK)
      begin
       if(CE)                   // If clock enable is active high then check for other control signals
        begin
         if(RST)                // If reset is active high all output signals are equal to zero
          begin
            RES=9'bzzzzzzzzz;
            COUT=1'bz;
            OFLOW=1'bz;
            G=1'bz;
            E=1'bz;
            L=1'bz;
            ERR=1'bz;
            AU_out_tmp1=0;
            AU_out_tmp2=0;
            
          end
 
         else if(MODE)          // Reset signal is active low. If MODE signal is high, then this is an Arithmetic Operation
         begin
           RES=9'bzzzzzzzzz;
           COUT=1'bz;
           OFLOW=1'bz;
           G=1'bz;
           E=1'bz;
           L=1'bz;
           ERR=1'bz;
          case(CMD_tmp)             // CMD_tmp is the binary code value of the Arithmetic Operation
    4'b0000:                   begin             
              RES=oprd1+oprd2;
              COUT=RES[8]?1:0;
            end
      4'b0001 :                begin
             OFLOW=(oprd1<oprd2)?1:0;
             RES=oprd1-oprd2;
            end
           4'h2:             // CMD_tmp = 0010: ADD_CIN
            begin
             RES=oprd1+oprd2+CIN;
             COUT=RES[8]?1:0;
            end
           4'b0011:             // CMD_tmp = 0011: SUB_CIN. Here we set the overflow flag
           begin
            OFLOW=(oprd1<oprd2)?1:0;
            RES=oprd1-oprd2-CIN;
           end
           4'b0100:RES=oprd1;    // CMD_tmp = 0100: INC_A 
           4'b0101:RES=oprd1-1;    // CMD_tmp = 0101: DEC_A
           4'b0110:RES=oprd2-1;    // CMD_tmp = 0110: INC_B 
           4'b0111:RES=oprd2+1;    // CMD_tmp = 0111: DEC_B 
           4'b1000:              // CMD_tmp = 1000: CMP
           begin
            RES=9'bzzzzzzzzz;
            if(oprd1==oprd2)
             begin
               E=1'b1;
               G=1'bz;
               L=1'bz;
             end
            else if(oprd1>oprd2)
             begin
               E=1'bz;
               G=1'b1;
               L=1'bz;
             end
            else 
             begin
               E=1'bz;
               G=1'bz;
               L=1'b1;
             end
           end
	   4'b1001: begin   //MP : oprd is incr and then multiplicationn ....3 cycle instruction/cmd
                    AU_out_tmp1 <= oprd1 + 1;
                    AU_out_tmp2 <= oprd2 + 1;
                    RES <=AU_out_tmp1 * AU_out_tmp2;
                  end
           4'b1010: begin   //MP : oprd_A is left shift and then mul with B ....3 cycle instruction/cmd
                    AU_out_tmp1 <= oprd1 << 1;
                    AU_out_tmp2 <= oprd2;
                    RES <=AU_out_tmp1 - AU_out_tmp2; 
                  end

           default:   // For any other case send high impedence value
            begin
            RES=9'bzzzzzzzzz;
            COUT=1'bz;
            OFLOW=1'bz;
            G=1'bz;
            E=1'bz;
            L=1'bz;
            ERR=1'bz;
           end
          endcase
         end
 
        else          // MODE signal is low, then this is a Logical Operation
        begin 
           RES=9'bzzzzzzzzz;
           COUT=1'bz;
           OFLOW=1'bz;
           G=1'bz;
           E=1'bz;
           L=1'bz;
           ERR=1'bz;
           case(CMD_tmp)    // CMD_tmp is the binary code value of the Logical Operation
             4'b0000:RES={1'b0,oprd1&oprd2};     // CMD_tmp = 0000: AND
             4'b0001:RES={1'b0,~(oprd1&oprd2)};  // CMD_tmp = 0001: NAND
             4'b0010:RES={1'b0,oprd1&&oprd2};     // CMD_tmp = 0010: OR
 	     4'b0011:RES={1'b0,~(oprd1|oprd2)};  // CMD_tmp = 0011: NOR
             4'b0100:RES={1'b0,oprd1^oprd2};     // CMD_tmp = 0100: XOR
             4'b0101:RES={1'b0,~(oprd1^oprd2)};  // CMD_tmp = 0101: XNOR
             4'b0110:RES={1'b0,~oprd1};        // CMD_tmp = 0110: NOT_A
             4'b0111:RES={1'b0,~oprd2};        // CMD_tmp = 0111: NOT_B
             4'b1000:RES={1'b0,oprd1>>1};      // CMD_tmp = 1000: SHR1_A 
             4'b1001:RES={1'b0,oprd1<<1};      // CMD_tmp = 1001: SHL1_A
             4'b1010:RES={1'b0,oprd2>>1};      // CMD_tmp = 1010: SHR1_B
             4'b1011:RES={1'b0,oprd2<<1};      // CMD_tmp = 1011: SHL1_B
             4'b1100:                        // CMD_tmp = 1100: ROL_A_B
             begin 
               if(oprd2[0])
                 OPA_1 = {oprd1[6:0], oprd1[7]};
               else
                 OPA_1 = oprd1;
 
               if(oprd2[1])
                 OPB_1 =  {OPA_1[5:0], OPA_1[7:6]}; 
               else
                 OPB_1= OPA_1;
 
               if(oprd2[2])
                 RES =  {OPB_1[3:0], OPB_1[7:4]} ;
               else
                 RES = OPB_1;
 
               if(oprd2[4] | oprd2[5] | oprd2[6] | oprd2[7])
                 ERR=1'b1;
             end
             4'b1101:                        // CMD_tmp = 1101: ROR_A_B 
             begin
               if(oprd2[0])
                 OPA_1 = {oprd1[0], oprd1[7:1]};
               else
                 OPA_1 = oprd1;
               if(oprd2[1])
                 OPB_1 =  {OPA_1[1:0], OPA_1[7:2]}; 
               else
                 OPB_1= OPA_1;
               if(oprd2[2])
                 RES =  {OPB_1[3:0], OPB_1[7:4]} ;
               else
                 RES = OPB_1;
               if(oprd2[4] | oprd2[5] | oprd2[6] | oprd2[7])
                 ERR=1'b0;
             end
             default:    // For any other case send high impedence value
               begin
               RES=9'bzzzzzzzzz;
               COUT=1'bz;
               OFLOW=1'bz;
               G=1'bz;
               E=1'bz;
               L=1'bz;
               ERR=1'bz;
               end
          endcase
     end
    end
   end
endmodule



