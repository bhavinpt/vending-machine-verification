
// ############################## 
// The item sent by the sequence
// ############################## 
class VendData extends uvm_sequence_item;
  rand bit signed [9:0] extraCoins;
  rand Coin coins[$];

  `uvm_object_utils_begin(VendData)
  `uvm_field_int(extraCoins,  UVM_ALL_ON)
  `uvm_field_queue_enum(Coin, coins,  UVM_ALL_ON)
  `uvm_object_utils_end

  constraint change_co_mod5 {extraCoins % 5 == 0;}
  constraint change_amt_neg_co {if (extraCoins < 0) (extraCoins * -1 < coins.sum());}
  constraint sum_co {coins.sum() > 0; coins.sum() % 5 == 0;}
  constraint order_co {solve coins before extraCoins;}

  function new(string name="VendData");
    super.new(name);
  endfunction : new

endclass : VendData
