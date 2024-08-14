class alu_sequence extends uvm_sequence#(alu_sequence_item);
  `uvm_object_utils(alu_sequence)            

 
  alu_sequence_item txn;

  function new(string name="alu_sequence");  
    super.new(name);
  endfunction

 

  virtual task body();
    txn=alu_sequence_item::type_id::create("txn");
    logical_op(txn);
    arithmetic_op_cin0(txn);
    arithmetic_op_cin1(txn);
  endtask:body
  // m==1 and logical operation 
  task logical_op(alu_sequence_item txn);
      for(int i=0;i<15;i++) begin
        start_item(txn);
        void'(txn.randomize()with{txn.cmd==i;txn.mode==1;txn.cin==0;});
        #5;
        finish_item(txn);
      end
  endtask

  // mode==0 and cin==0 ; arithmetic operation 
  task arithmetic_op_cin0(alu_sequence_item txn);
      for(int i=0;i<15;i++) begin
        start_item(txn);
        void'(txn.randomize()with{txn.cmd==i;txn.mode==0;txn.cin==0;});
        #5;
        finish_item(txn);
      end
  endtask
 
  // mode==0 and cin==1 ; arithmetic operation 
  task arithmetic_op_cin1(alu_sequence_item txn);
    for(int i=0;i<15;i++) begin
        start_item(txn);
        void'(txn.randomize()with{txn.cmd==i;txn.mode==0;txn.cin==1;});
        #5;
        finish_item(txn);
      end
  endtask
endclass
