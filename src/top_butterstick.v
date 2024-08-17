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
	    input [1:0]	 user_btn,


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
	    input 	 SYZYGY0_PMOD2A_1,
	    input 	 SYZYGY0_PMOD2A_2,
	    input 	 SYZYGY0_PMOD2A_3,
	    input 	 SYZYGY0_PMOD2A_4,
	    input 	 SYZYGY0_PMOD2A_7,
	    input 	 SYZYGY0_PMOD2A_8,
	    input 	 SYZYGY0_PMOD2A_9,
	    input 	 SYZYGY0_PMOD2A_10,
	    input 	 SYZYGY0_PMOD2B_1,
	    input 	 SYZYGY0_PMOD2B_2,
	    input 	 SYZYGY0_PMOD2B_3,
	    input 	 SYZYGY0_PMOD2B_4,
	    input 	 SYZYGY0_PMOD2B_7,
	    input 	 SYZYGY0_PMOD2B_8,
	    input 	 SYZYGY0_PMOD2B_9,
	    input 	 SYZYGY0_PMOD2B_10,

	    );

   assign led_rgb_multiplex_b = 3'b001;
   
   assign led_rgb_multiplex_a[0] = counter[25];
   assign led_rgb_multiplex_a[1] = SYZYGY0_PMOD2B_1;
   assign led_rgb_multiplex_a[6:2] = 5'b00000;

   assign pdm_en = 1'b1;
   assign pdm[0] = counter[18]; // 15 = 2.5V, 12 = 2.2V, 16 = 2.8V, 17 = 3.1V, 18 = 3.3V
   assign rst_n = user_btn[0];
   
   

   reg [0:9]		 rst_counter = 10'b11_1111_1111;

   reg			 rst;

   wire			 locked;
   wire			 clk_25_125;
   wire			 vga_sel;
   wire			 r0;
   wire			 r1;
   wire			 r2;
   wire			 r3;
   wire			 b0;
   wire			 b1;
   wire			 b2;
   wire			 b3;
   wire			 g0;
   wire			 g1;
   wire			 g2;
   wire			 g3;
   wire			 hs;
   wire			 vs;

   assign    vga_sel = SYZYGY0_PMOD2A_10;

   // P1A is pmod the right
   assign SYZYGY0_PMOD1A_1   = (vga_sel == 1'b1) ? r1 : r0;
   assign SYZYGY0_PMOD1A_2   = (vga_sel == 1'b1) ? g1 : r1;
   assign SYZYGY0_PMOD1A_3   = (vga_sel == 1'b1) ? b1 : r2;
   assign SYZYGY0_PMOD1A_4   = (vga_sel == 1'b1) ? vs : r3;
   assign SYZYGY0_PMOD1A_7   = (vga_sel == 1'b1) ? r0 : b0;
   assign SYZYGY0_PMOD1A_8   = (vga_sel == 1'b1) ? g0 : b1;
   assign SYZYGY0_PMOD1A_9   = (vga_sel == 1'b1) ? b0 : b2;
   assign SYZYGY0_PMOD1A_10  = (vga_sel == 1'b1) ? hs : b3;
   // P1B is pmod on left
   assign SYZYGY0_PMOD1B_1  =  g0;
   assign SYZYGY0_PMOD1B_2  =  g1;
   assign SYZYGY0_PMOD1B_3  =  g2;
   assign SYZYGY0_PMOD1B_4  =  g3;
   assign SYZYGY0_PMOD1B_7  =  hs;
   assign SYZYGY0_PMOD1B_8  =  vs;
   assign SYZYGY0_PMOD1B_9  =  1'b0;
   assign SYZYGY0_PMOD1B_10 =  1'b0;

   // POR delay
   always @ (posedge clk_25_125) begin
      if (rst_counter != 0) begin
	 rst <= 1'b1;
	 if (locked) begin
	    rst_counter <= rst_counter - 1;
	 end
      end else begin
	 rst <= 1'b0;
      end
   end

   vga vga(.clk(clk_25_125), 
	   .rst(rst),
           .left(!SYZYGY0_PMOD2B_1),
           .right(!SYZYGY0_PMOD2B_2),
           .score_reset(!SYZYGY0_PMOD2B_3),
           .speed_lsb(!SYZYGY0_PMOD2A_8),
           .speed_msb(!SYZYGY0_PMOD2A_9),
           .r0(r0),
           .r1(r1),
           .r2(r2),
           .r3(r3),
           .b0(b0),
           .b1(b1),
           .b2(b2),
           .b3(b3),
           .g0(g0),
           .g1(g1),
           .g2(g2),
           .g3(g3),
           .hs(hs),
           .vs(vs));


    // PLL
    // ecppll -i 30 -o 25.125 --highres -f tom
    // Pll parameters:
    // Refclk divisor: 8
    // Feedback divisor: 67
    // clkout0 divisor: 2
    // clkout0 frequency: 25.125 MHz
    // clkout1 divisor: 20
    // clkout1 frequency: 25.125 MHz
    // clkout1 phase shift: -1.78186e+29 degrees
    // VCO frequency: 502.5

wire clkfb;
(* FREQUENCY_PIN_CLKI="30" *)
(* FREQUENCY_PIN_CLKOS="25.125" *)
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .OUTDIVIDER_MUXA("DIVA"),
        .OUTDIVIDER_MUXB("DIVB"),
        .OUTDIVIDER_MUXC("DIVC"),
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKI_DIV(8),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(2),
        .CLKOP_CPHASE(9),
        .CLKOP_FPHASE(0),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(20),
        .CLKOS_CPHASE(1330285312),
        .CLKOS_FPHASE(65535),
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(67)
    ) pll_i (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clk30),
        .CLKOP(clkfb),
        .CLKOS(clk_25_125),
        .CLKFB(clkfb),
        .CLKINTFB(),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b1),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
	);

   // Infrastructure
   // Create a 32 bit register
   reg [31:0] counter = 0;

   // Every positive edge increment register by 1
   always @(posedge clk_25_125) begin
      if (1'b0) begin
	 counter <= 0;
      end else begin
         counter <= counter + 1;
      end
   end

endmodule
