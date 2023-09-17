
// ############################## 
// monitor class
// ############################## 
class VendMonitor extends uvm_driver #(VendData);
  VendData vendData;
  virtual Vend_interface vif;
  int amount = 0;
  uvm_analysis_port #(VendData) rxPort;
  uvm_analysis_port #(Coin) returnCoinPort;
  uvm_analysis_port #(int) buyAcceptPort;

  `uvm_component_utils_begin(VendMonitor)
  `uvm_field_object(vendData, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name="VendMonitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rxPort = new("rxPort", this);
    returnCoinPort = new("returnCoinPort", this);
    buyAcceptPort = new("buyAcceptPort", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual Vend_interface)::get(null, "", "intf", vif)) begin
      `uvm_error("VIF_GET_ERROR","COULD NOT GET VIF")
    end
  endfunction

  task run_phase(uvm_phase phase);
    // never-ending fork
    fork
      begin
	forever
	begin
	  @(posedge vif.return_5);
	  returnCoinPort.write(NICKEL);
	  amount+=5;
	end
      end
      begin
	forever
	begin
	  @(posedge vif.return_10);
	  returnCoinPort.write(DIME);
	  amount+=10;
	end
      end
      begin
	forever
	begin
	  @(posedge vif.return_25);
	  returnCoinPort.write(QUARTER);
	  amount+=25;
	end
      end
      begin
	forever
	begin
	  @(posedge vif.ok);
	  buyAcceptPort.write(amount);
	  amount = 0;
	end
      end

    join

  endtask : run_phase

  // Output process:


endclass : VendMonitor
