// ############################## 
// environment class
// ############################## 

class VendEnv extends uvm_env;
  VendDriver driver;
  VendMonitor monitor;
  VendSequencer sequencer;
  VendScoreboard scoreboard;

  `uvm_component_utils_begin(VendEnv)
  `uvm_field_object(driver, UVM_ALL_ON)
  `uvm_field_object(sequencer, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name="VendEnv", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = VendDriver::type_id::create("driver", this);
    monitor = VendMonitor::type_id::create("monitor", this);
    sequencer = VendSequencer::type_id::create("sequencer", this);
    scoreboard = VendScoreboard::type_id::create("scoreboard", this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    driver.addCoinPort.connect(scoreboard.addCoinPort);
    driver.buyAmountPort.connect(scoreboard.buyAmountPort);
    scoreboard.updateCoinCountPort.connect(driver.updateCoinCountPort);
    scoreboard.transCompletePort.connect(driver.transCompletePort);
    monitor.returnCoinPort.connect(scoreboard.returnCoinPort);
    monitor.buyAcceptPort.connect(scoreboard.buyAcceptPort);
  endfunction : connect_phase

endclass : VendEnv


