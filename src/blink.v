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

    // Every positive edge increment register by 1
    always @(posedge clk30) begin
        counter <= counter + 1;
    end

    // Output inverted values of counter onto LEDs
    assign led_rgb_multiplex_b = counter[26:24];
    assign led_rgb_multiplex_a = counter[31:25];



    assign SYZYGY0_PMOD1A_1  = counter[23];
    assign SYZYGY0_PMOD1A_2  = counter[24];
    assign SYZYGY0_PMOD1A_3  = counter[25];
    assign SYZYGY0_PMOD1A_4  = counter[26];
    assign SYZYGY0_PMOD1A_7  = counter[27];
    assign SYZYGY0_PMOD1A_8  = counter[28];
    assign SYZYGY0_PMOD1A_9  = counter[29];
    assign SYZYGY0_PMOD1A_10 = counter[30];

    assign SYZYGY0_PMOD1B_1  = counter[23];
    assign SYZYGY0_PMOD1B_2  = counter[24];
    assign SYZYGY0_PMOD1B_3  = counter[25];
    assign SYZYGY0_PMOD1B_4  = counter[26];
    assign SYZYGY0_PMOD1B_7  = counter[27];
    assign SYZYGY0_PMOD1B_8  = counter[28];
    assign SYZYGY0_PMOD1B_9  = counter[29];
    assign SYZYGY0_PMOD1B_10 = counter[30];

    assign SYZYGY0_PMOD2A_1  = counter[23];
    assign SYZYGY0_PMOD2A_2  = counter[24];
    assign SYZYGY0_PMOD2A_3  = counter[25];
    assign SYZYGY0_PMOD2A_4  = counter[26];
    assign SYZYGY0_PMOD2A_7  = counter[27];
    assign SYZYGY0_PMOD2A_8  = counter[28];
    assign SYZYGY0_PMOD2A_9  = counter[29];
    assign SYZYGY0_PMOD2A_10 = counter[30];
   
    assign SYZYGY0_PMOD2B_1  = counter[23];
    assign SYZYGY0_PMOD2B_2  = counter[24];
    assign SYZYGY0_PMOD2B_3  = counter[25];
    assign SYZYGY0_PMOD2B_4  = counter[26];
    assign SYZYGY0_PMOD2B_7  = counter[27];
    assign SYZYGY0_PMOD2B_8  = counter[28];
    assign SYZYGY0_PMOD2B_9  = counter[29];
    assign SYZYGY0_PMOD2B_10 = counter[30];

   assign pdm_en = 1'b1;
   assign pdm[0] = counter[18]; // 15 = 2.5V, 12 = 2.2V, 16 = 2.8V, 17 = 3.1V, 18 = 3.3V
   
   
endmodule
