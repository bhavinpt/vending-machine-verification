// Submitted By : Bhavin Patel

`timescale 1ns/10ps
`include "dut/vend.sv"       // pass
//`include "dut/vend1.svp"    // failed : keeps returning 5's after buy attempt with insufficient amount; doesn't returns 10's
//`include "dut/vend2.svp"    // failed : doesn't return all coins after buy decline
//`include "dut/vend3.svp"    // failed : keeps returning 10's after every buy
//`include "dut/vend4.svp"    // failed : keeps returning 25's after every buy; does not return full amount after invalid buy
//`include "dut/vend5.svp"    // failed : does not return full amount after declined buy; 10 cents missing 
//`include "dut/vend6.svp"    // failed : keeps returning 25's even when no return is expected and even after it returns all 25's it should have.
//`include "dut/vend7.svp"    // failed : does not return full amount after declined buy; 5 cents missing 
//`include "dut/vend8.svp"    // failed : returns unexpected extra 25's on a buy attempt that expects some returns
//`include "dut/vend9.svp"    // failed : returns 5's instead of 10's
// `include "dut/vend10.svp"  // failed : keeps returning 25's even when no return is expected and even after it returns all 25's it should have.


interface Vend_interface(
  input wire clk,
  input wire reset,
  input wire detect_5,
  input wire detect_10,
  input wire detect_25,
  input wire [8:0] amount,
  input wire buy,
  input wire return_coins,
  input wire empty_5,
  input wire empty_10,
  input wire empty_25,
  output wire ok,
  output wire return_5,
  output wire return_10,
  output wire return_25 

);

endinterface



module top();

reg clk;
reg reset;
wire detect_5; 
wire detect_10;
wire detect_25;
wire [8:0] amount;
wire buy;
wire return_coins; 

wire empty_5;
wire empty_10;
wire empty_25;
wire ok;
wire return_5; 
wire return_10;
wire return_25;

// module & interface 
vend vend_m(.*);
Vend_interface intf (.*);

// ---------------------------------------------------------------------------------
// testbench -- components 
// ---------------------------------------------------------------------------------

import uvm_pkg::*;
`include "types.sv"
`include "seq_item.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "env.sv"
`include "sequence.sv"
`include "test.sv"

// ---------------------------------------------------------------------------------
// top
// ---------------------------------------------------------------------------------

always #5 clk = ~clk;

initial begin
  clk = 0; 
  reset = 0;
  #100 reset = 1;
  #100 reset = 0;
end

initial begin
  $dumpfile("waves.vcd");
  $dumpvars;
  uvm_config_db #(virtual Vend_interface)::set(null, "*", "intf" , intf);
  run_test("VendTest");
  $finish;
end

endmodule : top




