`default_nettype none
`timescale 1ns/1ps

module tb (
           // testbench is controlled by test.py
	       input  clk
           );

  // this part dumps the trace to a vcd file that can be viewed with GTKWave
  initial begin
    $dumpfile ("tb.vcd");
    $dumpvars (0, tb.clk);
    $dumpvars (0, tb.blink.shift);
    $dumpvars (0, tb.blink.counter);
    #1;
  end

  // instantiate the DUT
   blink blink(.clk30(clk));
endmodule
