module top
  (
   input  CLK,
   input  P2_1,
   input  P2_2,
   input  P2_3,
   input  P2_4,
   input  P2_7,
   input  P2_8,
   input  P2_9,
   input  P2_10,
   output P1A1,
   output P1A2,
   output P1A3,
   output P1A4,
   output P1A7,
   output P1A8,
   output P1A9,
   output P1A10,
   output P1B1,
   output P1B2,
   output P1B3,
   output P1B4,
   output P1B7,
   output P1B8,
   output P1B9,
   output P1B10
   );

  reg [0:9] rst_counter = 10'b11_1111_1111;

  reg       rst;

  wire       locked;
  wire       clk_25_125;
  wire       vga_sel;

  wire               r0;
  wire               r1;
  wire               r2;
  wire               r3;
  wire               b0;
  wire               b1;
  wire               b2;
  wire               b3;
  wire               g0;
  wire               g1;
  wire               g2;
  wire               g3;
  wire               hs;
  wire               vs;
  
  assign    vga_sel = P2_10;

  // P1A is pmod the right
  assign P1A1   = (vga_sel == 1'b1) ? r1 : r0;
  assign P1A2   = (vga_sel == 1'b1) ? g1 : r1;
  assign P1A3   = (vga_sel == 1'b1) ? b1 : r2;
  assign P1A4   = (vga_sel == 1'b1) ? vs : r3;
  assign P1A7   = (vga_sel == 1'b1) ? r0 : b0;
  assign P1A8   = (vga_sel == 1'b1) ? g0 : b1;
  assign P1A9   = (vga_sel == 1'b1) ? b0 : b2;
  assign P1A10  = (vga_sel == 1'b1) ? hs : b3;
  // P1B is pmod on left
  assign P1B1  =  g0;
  assign P1B2  =  g1;
  assign P1B3  =  g2;
  assign P1B4  =  g3;
  assign P1B7  =  hs;
  assign P1B8  =  vs;
  assign P1B9  =  1'b0;
  assign P1B10 =  1'b0;

  // icepll -o 25.175 -m -p
  /*
   * PLL configuration
   *
   * This Verilog module was generated automatically
   * using the icepll tool from the IceStorm project.
   * Use at your own risk.
   *
   * Given input frequency:        12.000 MHz
   * Requested output frequency:   25.175 MHz
   * Achieved output frequency:    25.125 MHz
   */
  SB_PLL40_PAD #(
		         .FEEDBACK_PATH("SIMPLE"),
		         .DIVR(4'b0000),		// DIVR =  0
		         .DIVF(7'b1000010),	// DIVF = 66
		         .DIVQ(3'b101),		// DIVQ =  5
		         .FILTER_RANGE(3'b001)	// FILTER_RANGE = 1
		         ) pll (
			            .LOCK(locked),
			            .RESETB(1'b1),
			            .BYPASS(1'b0),
			            .PACKAGEPIN(CLK),
			            .PLLOUTCORE(clk_25_125)
			            );
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
          .left_up(!P2_1),
          .left_down(!P2_2),
          .right_up(!P2_3),
          .right_down(!P2_4),
          .score_reset(!P2_7),
          .speed_lsb(!P2_8),
          .speed_msb(!P2_9),
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
endmodule
