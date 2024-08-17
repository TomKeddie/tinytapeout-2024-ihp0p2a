/* Copyright 2020 Gregory Davill <greg.davill@gmail.com>
   Hacked 2021 by Tommy Thorn
*/
`default_nettype none

/*
 *  Blink an LED on the ButterStick r1.0 using Verilog
 */

module top (
    input	 clk30,
    output [6:0] led_rgb_multiplex_a,
    output [2:0] led_rgb_multiplex_b,

    output	 pdm_en,
    output [2:0] pdm,
    output	 rst_n,
    input  [1:0] user_btn,
	    
	    
    output	 SYZYGY0_PMOD1A_1,
    output	 SYZYGY0_PMOD1A_2,
    output	 SYZYGY0_PMOD1A_3,
    output	 SYZYGY0_PMOD1A_4,
    output	 SYZYGY0_PMOD1A_7,
    output	 SYZYGY0_PMOD1A_8,
    output	 SYZYGY0_PMOD1A_9,
    output	 SYZYGY0_PMOD1A_10,
    output	 SYZYGY0_PMOD1B_1,
    output	 SYZYGY0_PMOD1B_2,
    output	 SYZYGY0_PMOD1B_3,
    output	 SYZYGY0_PMOD1B_4,
    output	 SYZYGY0_PMOD1B_7,
    output	 SYZYGY0_PMOD1B_8,
    output	 SYZYGY0_PMOD1B_9,
    output	 SYZYGY0_PMOD1B_10,
    output	 SYZYGY0_PMOD2A_1,
    output	 SYZYGY0_PMOD2A_2,
    output	 SYZYGY0_PMOD2A_3,
    output	 SYZYGY0_PMOD2A_4,
    output	 SYZYGY0_PMOD2A_7,
    output	 SYZYGY0_PMOD2A_8,
    output	 SYZYGY0_PMOD2A_9,
    output	 SYZYGY0_PMOD2A_10,
    output	 SYZYGY0_PMOD2B_1,
    output	 SYZYGY0_PMOD2B_2,
    output	 SYZYGY0_PMOD2B_3,
    output	 SYZYGY0_PMOD2B_4,
    output	 SYZYGY0_PMOD2B_7,
    output	 SYZYGY0_PMOD2B_8,
    output	 SYZYGY0_PMOD2B_9,
    output	 SYZYGY0_PMOD2B_10,

);
    // Create a 32 bit register
    reg [31:0] counter = 0;
   reg [31:0]  shift = 32'h0000_0001;
   reg	       counter23_1d;
   

    // Every positive edge increment register by 1
    always @(posedge clk30) begin
        counter <= counter + 1;
    end

    assign led_rgb_multiplex_b = counter[26:24];
    assign led_rgb_multiplex_a = counter[31:25];

   always @(posedge clk30) begin
      counter23_1d <= counter[23];
      if (counter[23] && !counter23_1d) begin
	 shift <= {shift[30:0], shift[31]};
      end
   end

    assign SYZYGY0_PMOD1A_1  = shift[0];
    assign SYZYGY0_PMOD1A_2  = shift[1];
    assign SYZYGY0_PMOD1A_3  = shift[2];
    assign SYZYGY0_PMOD1A_4  = shift[3];
    assign SYZYGY0_PMOD1A_7  = shift[4];
    assign SYZYGY0_PMOD1A_8  = shift[5];
    assign SYZYGY0_PMOD1A_9  = shift[6];
    assign SYZYGY0_PMOD1A_10 = shift[7];

    assign SYZYGY0_PMOD1B_1  = shift[8];
    assign SYZYGY0_PMOD1B_2  = shift[9];
    assign SYZYGY0_PMOD1B_3  = shift[10];
    assign SYZYGY0_PMOD1B_4  = shift[11];
    assign SYZYGY0_PMOD1B_7  = shift[12];
    assign SYZYGY0_PMOD1B_8  = shift[13];
    assign SYZYGY0_PMOD1B_9  = shift[14];
    assign SYZYGY0_PMOD1B_10 = shift[15];

    assign SYZYGY0_PMOD2A_1  = shift[16];
    assign SYZYGY0_PMOD2A_2  = shift[17];
    assign SYZYGY0_PMOD2A_3  = shift[18];
    assign SYZYGY0_PMOD2A_4  = shift[19];
    assign SYZYGY0_PMOD2A_7  = shift[20];
    assign SYZYGY0_PMOD2A_8  = shift[21];
    assign SYZYGY0_PMOD2A_9  = shift[22];
    assign SYZYGY0_PMOD2A_10 = shift[23];
   
    assign SYZYGY0_PMOD2B_1  = shift[24];
    assign SYZYGY0_PMOD2B_2  = shift[25];
    assign SYZYGY0_PMOD2B_3  = shift[26];
    assign SYZYGY0_PMOD2B_4  = shift[27];
    assign SYZYGY0_PMOD2B_7  = shift[28];
    assign SYZYGY0_PMOD2B_8  = shift[29];
    assign SYZYGY0_PMOD2B_9  = shift[30];
    assign SYZYGY0_PMOD2B_10 = shift[31];

   assign pdm_en = 1'b1;
   assign pdm[0] = counter[18]; // 15 = 2.5V, 12 = 2.2V, 16 = 2.8V, 17 = 3.1V, 18 = 3.3V
   assign rst_n = user_btn[0];
   
   
endmodule
