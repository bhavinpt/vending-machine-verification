# Vending Machine Verification

In this project, I developed a UVM test bench to verify a vending machine design. The testbench includes standard components such as Test, Environment, Agent, Driver, and Monitor, along with Virtual Sequencer, Virtual Sequence, Top, and Virtual Interfaces.

The vending machine operates in a mode where users can select products, make payments, and receive items. The testbench tests various scenarios, such as product selections, payment methods, and error injections, to ensure the vending machine functions correctly.

The test plan covers cases like successful purchases, handling errors, and verifying appropriate responses. The scoreboard component compares expected responses with actual ones, identifying any issues in the design.

After executing the testbench, we analyze the results to confirm the vending machine operates without bugs or problems. The UVM testbench provides comprehensive verification, ensuring the vending machine design meets all requirements.

![EE273 vending machine-Page-2 drawio](https://github.com/bhavinpt/vending-machine-verification/assets/117598876/2c8b0c48-a138-45ab-a32c-7374121a84d8 "Design Input and Outputs")

## Testbench Setup

The setup is a simple version of a standard UVM testbench. 
The sequence item is convenient to generate all unique scenarios such as buy with random coins & buy amount, buy decline & accept with spare change return.
The scoreboard uses a Bank object to keep track of and manage all the coins  and also validate all the purchases.

![EE273 vending machine-Page-1 drawio](https://github.com/bhavinpt/vending-machine-verification/assets/117598876/d5d550f3-d052-46fd-9a43-b52820fe104a "Testbench Setup")

## Results

1 non-encrypted(working) + 10 encrypted(for testing) DUTs were provided. 
The task was to identify all the failing DUTs and report them.

### Here is the type of errors captured for each DUT
- vend.sv      // pass (as expected)
- vend1.svp    // failed : keeps returning 5's after buy attempt with insufficient amount; doesn't returns 10's
- vend2.svp    // failed : doesn't return all coins after buy decline
- vend3.svp    // failed : keeps returning 10's after every buy
- vend4.svp    // failed : keeps returning 25's after every buy; does not return full amount after invalid buy
- vend5.svp    // failed : does not return full amount after declined buy; 10 cents missing 
- vend6.svp    // failed : keeps returning 25's even when no return is expected and even after it returns all 25's it should have.
- vend7.svp    // failed : does not return full amount after declined buy; 5 cents missing 
- vend8.svp    // failed : returns unexpected extra 25's on a buy attempt that expects some returns
- vend9.svp    // failed : returns 5's instead of 10's
- vend10.svp   // failed : keeps returning 25's even when no return is expected and even after it returns all 25's it should have.

### Here is the list of scoreboard checkers that captured the above errors
- [**BUY_WITHOUT_ADD**] : Triggered Buy before adding any coins
- [**INVALID_BUY**] : Buy of %d accepted just with %d amount
- [**RETURN_COIN_ERROR**] : Did not return %d amount of coins after last buy decline
- [**RETURNED_COIN_WHEN_EMPTY**] : Returned coin 5 when it was empty
- [**RETURNED_EXTRA_COIN**] : Returned extra coin 5
- [**RETURNED_COIN_WHEN_EMPTY**] : Returned coin 10 when it was empty
- [**RETURNED_EXTRA_COIN**] : Returned extra coin 10
- [**RETURNED_COIN_WHEN_EMPTY**] : Returned coin 25 when it was empty
- [**RETURNED_EXTRA_COIN**] : Returned extra coin 25
