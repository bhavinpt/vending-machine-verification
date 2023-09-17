
// ############################## 
// driver class
// ############################## 
`uvm_analysis_imp_decl(_coincount_drv)
`uvm_analysis_imp_decl(_trans_complete)
class VendDriver extends uvm_driver #(VendData);
  VendData vendData;
  virtual Vend_interface vif;
  uvm_analysis_port #(Coin) addCoinPort;
  uvm_analysis_port #(int) buyAmountPort;
  uvm_analysis_imp_coincount_drv #(CoinCount, VendDriver) updateCoinCountPort;
  uvm_analysis_imp_trans_complete #(bit, VendDriver) transCompletePort;
  bit signed [9:0] amount;
  uvm_event transCompleteEvent;

  `uvm_component_utils_begin(VendDriver)
  `uvm_field_object(vendData, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name="VendDriver", uvm_component parent = null);
    super.new(name, parent);
    addCoinPort = new("addCoinPort", this);
    buyAmountPort = new("buyAmountPort", this);
    updateCoinCountPort = new("updateCoinCountPort", this);
    transCompletePort = new("transCompletePort", this);
    transCompleteEvent = new("transCompleteEvent");
  endfunction : new

  virtual function void connect_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual Vend_interface)::get(null, "", "intf", vif))
    begin
      `uvm_error("VIF_GET_ERROR","COULD NOT GET VIF")
    end
  endfunction

  virtual function void write_coincount_drv(CoinCount coincount);
    //$display("updating coincount for %d to %d", coincount.coin, coincount.count);
    case(coincount.coin)
      NICKEL: vif.empty_5 = (coincount.count == 0) ? 1 : 0;
      DIME: vif.empty_10 = (coincount.count == 0) ? 1 : 0;
      QUARTER: vif.empty_25 = (coincount.count == 0) ? 1 : 0;
    endcase
  endfunction

  virtual function void write_trans_complete(bit complete);
    transCompleteEvent.trigger(); 
  endfunction

  task run_phase(uvm_phase phase);
    vif.return_coins = 0;
    vif.buy = 0;
    vif.amount = 0;

    // wait for initial reset
    @(negedge vif.reset);

    forever begin
      seq_item_port.get_next_item(vendData); // get the sequence item from sequencer

      $display("\n\n\n\n>>>>>>>>>>>>>>>> Transaction STARTED <<<<<<<<<<<<<<<<\n\n");
      vendData.print();

      // step 1: put in all the coins and calculate amount
      amount = 0;
      foreach(vendData.coins[ii]) begin
	@(posedge vif.clk);
	case(vendData.coins[ii]) 
	  NICKEL: begin
	    vif.detect_5 = 1;
	    vif.detect_10 = 0;
	    vif.detect_25 = 0;
	    amount+= 5;
	    addCoinPort.write(NICKEL);
	  end
	  DIME:  begin
	    vif.detect_5 = 0;
	    vif.detect_10 = 1;
	    vif.detect_25 = 0;
	    amount+= 10;
	    addCoinPort.write(DIME);
	  end
	  QUARTER:  begin
	    vif.detect_5 = 0;
	    vif.detect_10 = 0;
	    vif.detect_25 = 1;
	    amount+= 25;
	    addCoinPort.write(QUARTER);
	  end	 
	endcase 

	@(posedge vif.clk);
	vif.detect_5 = 0;
	vif.detect_10 = 0;
	vif.detect_25 = 0;
	repeat(50) @(posedge vif.clk);
      end
      amount -= vendData.extraCoins; // result should not be negative
      vif.amount = amount[8:0];
      repeat(50) @(posedge vif.clk);

      fork
	begin

	  // step 2: buy
	  @(posedge vif.clk);
	  vif.detect_5 = 0;
	  vif.detect_10 = 0;
	  vif.detect_25 = 0;
	  vif.buy = 1;
	  buyAmountPort.write(amount[8:0]);
	  @(posedge vif.clk);
	  vif.buy = 0;
	  repeat(50) @(posedge vif.clk);


	  // step 3: return 
	  @(posedge vif.clk);
	  vif.return_coins = 1;
	  @(posedge vif.clk);
	  vif.return_coins = 0;
	end
	begin

	  // step 4: wait for complete
	  transCompleteEvent.wait_trigger();
	end
      join
      $display("\n\n<<<<<<<<<<<<<<<< Transaction COMPLETE >>>>>>>>>>>>>>>>\n\n\n\n");
      repeat(50) @(posedge vif.clk);
      #25000;
      seq_item_port.item_done(vendData);
    end 
  endtask : run_phase

endclass : VendDriver
