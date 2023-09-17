// ############################## 
// test class
// ############################## 

class VendTest extends uvm_test;
  VendEnv env;
  VendSequence seq;

  `uvm_component_utils_begin(VendTest)
  `uvm_field_object(env, UVM_ALL_ON)
  `uvm_field_object(seq, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name = "VendTest", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase( uvm_phase phase);
    super.build_phase(phase);
    env = VendEnv::type_id::create("env", this);
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);

    // create and start sequence
    seq = VendSequence::type_id::create("seq", this);
    seq.start(env.sequencer);

    phase.drop_objection(this);
  endtask : run_phase

endclass : VendTest



