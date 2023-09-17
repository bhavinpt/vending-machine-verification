typedef enum {
  IDLE,
  ADD_COIN,
  ACCEPT_BUY,
  DECLINE_BUY
} BankState;

class Bank;
  int avail5 = 0;
  int avail10 = 0;
  int avail25 = 0;
  int openingBalance= 0;
  int buyAmount = 0;
  int returnChange = 0;
  BankState state = IDLE;
  uvm_event transCompleteEvent;

  // to set initial balance in bank
  function void setBalance(int new5, new10, new25);
    avail5 = new5;
    avail10 = new10;
    avail25 = new25;
    state = IDLE;
    transCompleteEvent = new("transCompleteEvent");
  endfunction

  // called when buy is triggered
  function void setBuyAmount(int buyAmount);
    int inputBalance = getCurrentBalance() - openingBalance;
    if(state != ADD_COIN) begin
      `uvm_error("BUY_WITHOUT_ADD", $sformatf("Triggered Buy before adding any coins"))
      return;
    end

    this.buyAmount = buyAmount;

    $display("Detected - Buy Initiated for Amount: %0d @t=%0t", buyAmount, $time);
    $display("Detected - Amount Added for this Buy: %0d @t=%0t", inputBalance, $time);
    if (inputBalance >= buyAmount) begin
      state = ACCEPT_BUY;
      returnChange = inputBalance - buyAmount;
      $display("Expected - Should ACCEPT buy");
      $display("Expected - Should return amount %0d", returnChange);
    end
    else begin
      state = DECLINE_BUY;
      returnChange = inputBalance;
      $display("Expected - Should DECLINE buy");
      $display("Expected - Should return amount %0d", returnChange);
    end

  endfunction

  // to finish current buy action
  function void finishTrans();
    printStatement("After Trans End");
    transCompleteEvent.trigger();
  endfunction

  // called when ok is triggered
  function void verifyBuyAccept();
    $display("Detected - Buy Accept detected @t=%0t", $time);
    if(state != ACCEPT_BUY) begin
      `uvm_error("INVALID_BUY", $sformatf("Buy of %d accepted just with %d amount", buyAmount, getCurrentBalance() - openingBalance))
    end 
    else begin
      if(returnChange == 0) begin
	finishTrans();
      end
    end
  endfunction 

  // called when detect_* is triggered
  function void addCoin(Coin coin);
    $display("Detected - Added Coin: %5d @t=%0t", coin, $time);
    if(state != ADD_COIN) begin
      openingBalance = getCurrentBalance();
    end
    // check if all change is returned on previous transaction
    if(state == DECLINE_BUY) begin
      if(getCurrentBalance() != openingBalance) begin
	`uvm_error("RETURN_COIN_ERROR", $sformatf("Did not return %d amount of coins after last buy decline", getCurrentBalance() - openingBalance))
      end
    end
    case(coin)
      NICKEL:avail5++;
      DIME: avail10++;
      QUARTER: avail25++;
    endcase
    state = ADD_COIN;
  endfunction

  // called when return_* is triggered
  function void removeCoin(Coin coin);
    int coinsLeft = 0;
    bit validReturn = 0;
    case(coin)
      NICKEL:
      begin
	if(avail5 == 0) begin
	  `uvm_error("RETURNED_COIN_WHEN_EMPTY", $sformatf("Returned coin 5 when it was empty"))
	end
	else if (returnChange < 5) begin
	  `uvm_error("RETURNED_EXTRA_COIN", $sformatf("Returned extra coin 5"))
	end
	else begin
	  avail5--;
	  returnChange -=5;
	  coinsLeft = avail5;
	  validReturn = 1;
	end
      end
      DIME:
      begin
	if(avail10 == 0) begin
	  `uvm_error("RETURNED_COIN_WHEN_EMPTY", $sformatf("Returned coin 10 when it was empty"))
	end
	else if (returnChange < 10) begin
	  `uvm_error("RETURNED_EXTRA_COIN", $sformatf("Returned extra coin 10"))
	end
	else begin
	  avail10--;
	  returnChange -=10;
	  coinsLeft = avail10;
	  validReturn = 1;
	end
      end
      QUARTER: 
      begin
	if(avail25 == 0) begin
	  `uvm_error("RETURNED_COIN_WHEN_EMPTY", $sformatf("Returned coin 25 when it was empty"))
	end
	else if (returnChange < 25) begin
	  `uvm_error("RETURNED_EXTRA_COIN", $sformatf("Returned extra coin 25"))
	end
	else begin
	  avail25--;
	  returnChange -=25;
	  coinsLeft = avail25;
	  validReturn = 1;
	end
      end
    endcase

    $display("Detected - Returned Coin: %0d (remaining-return: %0d, remaining %0d's: %0d) [valid:%0d] @t=%0t", coin, returnChange, coin, coinsLeft, validReturn, $time);

    if(validReturn && returnChange == 0) begin
      finishTrans();
    end
  endfunction

  // returns the count of given coin type 
  function int getAvailable(Coin coinType);
    case(coinType)
      NICKEL: return avail5; 
      DIME: return avail10; 
      QUARTER: return avail25; 
    endcase
  endfunction

  // returns the total amount in bank 
  function int getCurrentBalance();
    return avail5 * 5 + avail10 * 10 + avail25 * 25;
  endfunction

  // prints bank statement
  function void printStatement(string msg = "");
    $display("------------------------------------------------------------");
    $display("Bank Balance - %s [@t=%0t]", msg, $time);
    $display("\t IN_CART : %10d", getCurrentBalance() - openingBalance);
    $display("\t TOTAL   : %10d", getCurrentBalance());
    $display("\t nickles   : %10d", avail5);
    $display("\t dimes 	   : %10d", avail10);
    $display("\t quarters  : %10d", avail25);
    $display("------------------------------------------------------------");
  endfunction
endclass : Bank

// ############################## 
// scoreboard class
// ############################## 

`uvm_analysis_imp_decl(_add_coin)
`uvm_analysis_imp_decl(_buy_amount)
`uvm_analysis_imp_decl(_return_coin)
`uvm_analysis_imp_decl(_buy_accept)
class VendScoreboard extends uvm_scoreboard;
  uvm_analysis_imp_add_coin #(Coin, VendScoreboard) addCoinPort;
  uvm_analysis_port #(CoinCount) updateCoinCountPort;
  uvm_analysis_imp_buy_amount #(int, VendScoreboard) buyAmountPort;
  uvm_analysis_imp_return_coin #(Coin, VendScoreboard) returnCoinPort;
  uvm_analysis_imp_buy_accept #(int, VendScoreboard) buyAcceptPort;
  uvm_analysis_port #(bit) transCompletePort;

  Bank bank;

  `uvm_component_utils_begin(VendScoreboard)
  `uvm_component_utils_end

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    addCoinPort = new("addCoinPort", this);
    buyAmountPort = new("buyAmountPort", this);
    updateCoinCountPort = new("updateCoinCountPort", this);
    returnCoinPort = new("returnCoinPort", this);
    buyAcceptPort = new("buyAcceptPort", this);
    transCompletePort = new("transCompletePort", this);
  bank = new();   endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    int count = 0;
    bank.setBalance(count,count,count);// initial 5,count,25 coins in bank are count each (temporary)
    updateCoinCountPort.write('{NICKEL, count});
    updateCoinCountPort.write('{DIME, count});
    updateCoinCountPort.write('{QUARTER, count});
    bank.printStatement("Initial Balance");
  endfunction

  virtual function void write_add_coin(Coin coin);
    bank.addCoin(coin);
    updateCoinCountPort.write('{coin, bank.getAvailable(coin)});
  endfunction : write_add_coin

  virtual function void write_buy_amount(int amount);
    bank.printStatement("On Buy");
    bank.setBuyAmount(amount);
  endfunction : write_buy_amount

  virtual function void write_return_coin(Coin coin);
    bank.removeCoin(coin);
    updateCoinCountPort.write('{coin, bank.getAvailable(coin)});
  endfunction: write_return_coin

  virtual function void write_buy_accept(int amount);
    bank.verifyBuyAccept();
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      bank.transCompleteEvent.wait_trigger();
      transCompletePort.write(1);
    end
  endtask

endclass : VendScoreboard


