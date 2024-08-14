module top
  (
   input	CLK100MHZ,
   input [7:0]	ja,
   output [7:0]	jb,
   output [7:0]	jc
   );

   reg [0:9]	rst_counter = 10'b11_1111_1111;

   reg		rst;

   wire		locked;
   wire		clk_25_125;
   
   clk_wiz_0 pll ( .locked(locked),
		   .clk_in1(CLK100MHZ),
		   .clk_out1(clk_25_125)
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
           .left_up(!ja[0]),
           .left_down(!ja[1]),
           .right_up(!ja[2]),
           .right_down(!ja[3]),
           .score_reset(!ja[7]),
           .speed_lsb(!ja[5]),
           .speed_msb(!ja[6]),
	   .r0(jb[0]),
	   .r1(jb[1]),
	   .r2(jb[2]),
	   .r3(jb[3]),
	   .b0(jb[4]),
	   .b1(jb[5]),
	   .b2(jb[6]),
	   .b3(jb[7]),
	   .g0(jc[0]),
	   .g1(jc[1]),
	   .g2(jc[2]),
	   .g3(jc[3]),
	   .hs(jc[4]),
	   .vs(jc[5]));
endmodule
