

// ############################## 
// sequence class
// ############################## 
class VendSequence extends uvm_sequence #(VendData) ;
  VendData vendData;
  VendData vendDataRx;
  int i = 0;
  virtual Vend_interface vif;

  `uvm_object_utils_begin(VendSequence)
  `uvm_field_object(vendData, UVM_ALL_ON)
  `uvm_field_object(vendDataRx, UVM_ALL_ON)
  `uvm_object_utils_end

  `uvm_declare_p_sequencer(VendSequencer)

  function new(string name="VendSequence");
    super.new(name);
  endfunction : new


  virtual task pre_body();
    if (!uvm_config_db#(virtual Vend_interface)::get(null, "", "intf", vif))
      `uvm_error("VIF_GET_ERROR","COULD NOT GET VIF")
    endtask

    task body();

      // no change expected 
      repeat(2) begin
	`uvm_do_with(vendData, 
	{ 
	  coins.sum() inside {[50:300]};  // total amount of coins
	  coins.size() inside {[10:20]};  // number of coins
	  extraCoins == 0;		  // total amount of change
	})
	get_response(vendDataRx);
      end

      // change expected 
      repeat(2) begin
	`uvm_do_with(vendData, 
	{ 
	  coins.sum() inside {[50:300]};  // total amount of coins
	  coins.size() inside {[10:20]};  // number of coins
	  extraCoins > 0;    		  // total amount of change
	  extraCoins < 50;    		  // total amount of change
	})
	get_response(vendDataRx);
      end

      // buy decline expected 
      repeat(2) 
      begin
	`uvm_do_with(vendData, 
	{ 
	  coins.sum() inside {[50:300]};  // total amount of coins
	  coins.size() inside {[10:20]};  // number of coins
	  extraCoins < 0;    		  // total amount of change
	})
	get_response(vendDataRx);
      end




      #250000; // drain time

    endtask : body

endclass : VendSequence

