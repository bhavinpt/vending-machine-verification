// ############################## 
// sequencer class
// ############################## 

class VendSequencer extends uvm_sequencer #(VendData);
  `uvm_component_utils(VendSequencer)

  function new(string name="VendSequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : VendSequencer

