
module vga(
	   input  clk,
	   input  rst,
           input  left_up,
           input  left_down,
           input  right_up,
           input  right_down,
           input  score_reset,
           input  speed_lsb,
           input  speed_msb,
	   output r0,
	   output r1,
	   output r2,
	   output r3,
	   output g0,
	   output g1,
	   output g2,
	   output g3,
	   output b0,
	   output b1,
	   output b2,
	   output b3,
	   output hs,
	   output vs
	   );

   localparam	  h_visible    = 640 - 1;
   localparam	  h_frontporch = 640 + 16 - 1;
   localparam	  h_sync       = 640 + 16 + 96 - 1;
   localparam	  h_backporch  = 640 + 16 + 96 + 48 - 1;

   // while h_sync is being sent, vertical counts h_sync pulses, for
   // porch and sync, it counts clocks
   localparam	  v_visible    = 480 - 1;
   localparam	  v_frontporch = 480 + 14 - 1;
   localparam	  v_sync       = 480 + 14 + 3 - 1;
   localparam	  v_backporch  = 480 + 14 + 3 + 31 - 1;

   localparam	  paddle_size_v = 40;
   localparam	  paddle_size_h = 6;

   localparam	  paddle_l_pos_h    = 15 - 1;
   localparam	  paddle_r_pos_h    = 625 - 1;
   
   localparam	  ball_size_v = 4;
   localparam	  ball_size_h = 4;

   localparam	  score_pos_v       = 20 - 1;  // 20-69
   localparam	  score_l_pos_h     = 255 - 1; // 255-304
   localparam	  score_r_pos_h     = 335 - 1; // 335-384
   localparam	  score_unit        = 10;
   
   wire		  blank;
   reg		  blank_h;
   reg		  blank_v;

   assign blank = (blank_h | blank_v);

   // 2^10  = 1024
   reg [9:0]	  count_h;
   reg [9:0]	  count_v;
   
   reg [8:0]	  paddle_l_pos_v;
   reg [8:0]	  paddle_r_pos_v;

   reg [9:0]	  ball_pos_h;
   reg [8:0]	  ball_pos_v;
   reg		  ball_motion_l;
   reg [2:0]	  ball_ratio;
   reg [3:0]	  ball_angle; // msb is up(1)/down(0)

   reg [4:0]	  score_l;
   reg [2:0]	  score_l_unit_pixels;
   reg		  score_l_ten_enable;
   reg [4:0]	  score_r;
   reg [2:0]	  score_r_unit_pixels;
   reg		  score_r_ten_enable;
   
   reg		  red;
   reg		  grn;
   reg		  blu;
   wire		  fg;
   wire		  bg;
   reg		  hs_out;
   reg		  vs_out;

   reg		  left_up_1d;
   reg		  left_down_1d;
   reg		  right_up_1d;
   reg		  right_down_1d;

   reg		  left_up_pressed;
   reg		  left_down_pressed;
   reg		  right_up_pressed;
   reg		  right_down_pressed;
   reg [24:0]	  interval_counter;

   reg	  speed_lsb_1d;
   reg	  speed_msb_1d;
   
   assign r0 = red;
   assign r1 = red;
   assign r2 = red;
   assign r3 = red;
   assign b0 = blu;
   assign b1 = blu;
   assign b2 = blu;
   assign b3 = blu;
   assign g0 = grn;
   assign g1 = grn;
   assign g2 = grn;
   assign g3 = grn;
   assign hs = !hs_out;
   assign vs = !vs_out;

   always @ (posedge clk) begin
      if (rst) begin
	 red <= 1'b0;
	 grn <= 1'b0;
	 blu <= 1'b0;
      end else begin
	 red <= fg;
	 grn <= fg;
	 blu <= bg;
      end
   end

   assign bg  = (blank) ? 1'b0 : 1'b1;

   assign fg  = (blank) ? 1'b0 :
		// outline (DEBUG)
		// (count_h == 0 || count_h == 639 || count_v == 0 | count_v == 479) ? 1'b1 :
                // dashed net down the centre
                (count_h > 317-1 && count_h < 323-1 && count_v[4] == 1'b0) ? 1'b1 :
                // left paddle
                (count_h >= paddle_l_pos_h-paddle_size_h && count_h < paddle_l_pos_h && count_v >= (paddle_l_pos_v-paddle_size_v/2) && count_v < (paddle_l_pos_v+paddle_size_v/2)-1) ? 1'b1 :
                // right paddle
                (count_h >= paddle_r_pos_h && count_h < paddle_r_pos_h+paddle_size_h && count_v >= (paddle_r_pos_v-paddle_size_v/2) && count_v < (paddle_r_pos_v+paddle_size_v/2)-1) ? 1'b1 :
                // ball
                (count_h >= (ball_pos_h-ball_size_h/2) && count_h < (ball_pos_h+ball_size_h/2)-1 && count_v > (ball_pos_v-ball_size_v/2) && count_v < (ball_pos_v+ball_size_v/2)) ? 1'b1 :
                // left score ten digit
                (count_h >= score_l_pos_h+5+0*score_unit && count_h < score_l_pos_h+5+1*score_unit && count_v >= score_pos_v+0*score_unit && count_v < score_pos_v+5*score_unit) ? score_l_ten_enable :
                // left score unit digit
                (count_h >= score_l_pos_h+20+0*score_unit && count_h < score_l_pos_h+20+1*score_unit && count_v >= score_pos_v+0*score_unit && count_v < score_pos_v+5*score_unit) ? score_l_unit_pixels[2] :
                (count_h >= score_l_pos_h+20+1*score_unit && count_h < score_l_pos_h+20+2*score_unit && count_v >= score_pos_v+0*score_unit && count_v < score_pos_v+5*score_unit) ? score_l_unit_pixels[1] :
                (count_h >= score_l_pos_h+20+2*score_unit && count_h < score_l_pos_h+20+3*score_unit && count_v >= score_pos_v+0*score_unit && count_v < score_pos_v+5*score_unit) ? score_l_unit_pixels[0] :
                // right score ten digit
                (count_h >= score_r_pos_h+5+0*score_unit && count_h < score_r_pos_h+5+1*score_unit && count_v >= score_pos_v+0*score_unit && count_v < score_pos_v+5*score_unit) ? score_r_ten_enable :
                // right score unit digit
                (count_h >= score_r_pos_h+20+0*score_unit && count_h < score_r_pos_h+20+1*score_unit && count_v >= score_pos_v+0*score_unit && count_v < score_pos_v+5*score_unit) ? score_r_unit_pixels[2] :
                (count_h >= score_r_pos_h+20+1*score_unit && count_h < score_r_pos_h+20+2*score_unit && count_v >= score_pos_v+0*score_unit && count_v < score_pos_v+5*score_unit) ? score_r_unit_pixels[1] :
                (count_h >= score_r_pos_h+20+2*score_unit && count_h < score_r_pos_h+20+3*score_unit && count_v >= score_pos_v+0*score_unit && count_v < score_pos_v+5*score_unit) ? score_r_unit_pixels[0] :
                // background
                1'b0;

   // Horizontal
   always @ (posedge clk) begin
      hs_out           <= 1'b0;
      if (rst) begin
	 count_h <= 10'b11_1111_1111;
	 blank_h <= 1'b1;
      end else if (count_h < h_visible) begin
	 // horizontal visible
	 count_h <= count_h + 1;
      end else if (count_h < h_frontporch) begin
	 // horizontal front porch
	 count_h <= count_h + 1;
	 blank_h <= 1'b1;
      end else if (count_h < h_sync) begin
	 // horizontal sync
	 count_h <= count_h + 1;
	 hs_out <= 1'b1;
      end else if (count_h < h_backporch) begin
	 // horizontal back porch
	 count_h <= count_h + 1;
      end else begin
	 count_h <= 0;
	 blank_h <= 1'b0;
      end
   end

   // Vertical
   always @ (posedge clk) begin
      if (rst) begin
	 count_v              <= 10'b1_1111_1111;
	 blank_v              <= 1'b1;
	 vs_out               <= 1'b0;
      end else if (count_h >= h_backporch) begin
	 if (count_v < v_visible) begin
            // vertical visible
            count_v <= count_v + 1;
	 end else if (count_v < v_backporch) begin
            count_v <= count_v + 1;
            blank_v <= 1'b1;
            if (count_v > v_frontporch && count_v < v_sync) begin
               vs_out <= 1'b1;
            end else begin
               vs_out <= 1'b0;
            end
	 end else begin
            count_v <= 0;
            blank_v <= 1'b0;
	 end
      end
   end

   // counter
   always @ (posedge clk) begin
      if (rst) begin
	 interval_counter <= 0;
	 speed_msb_1d <= 1'b0;
	 speed_lsb_1d <= 1'b0;
      end else begin
	 speed_msb_1d <= speed_msb;
	 speed_lsb_1d <= speed_lsb;
	 if (speed_lsb != speed_lsb_1d || speed_msb != speed_msb_1d) begin
	    interval_counter <= 0;
	 end else if (speed_lsb == 1'b0 && speed_msb == 1'b0 && interval_counter != 251750 ||
             speed_lsb == 1'b1 && speed_msb == 1'b0 && interval_counter != 251750*6/9 ||
             speed_lsb == 1'b0 && speed_msb == 1'b1 &&  interval_counter != 251750*4/9 ||
             speed_lsb == 1'b1 && speed_msb == 1'b1 &&  interval_counter != 251750*3/9) begin
            interval_counter <= interval_counter + 1;
	 end else begin
            interval_counter <= 0;
	 end
      end
   end
   
   // paddle debounce
   always @ (posedge clk) begin
      begin
	 left_up_pressed    <= 1'b0;
	 left_down_pressed  <= 1'b0;
	 right_up_pressed   <= 1'b0;
	 right_down_pressed <= 1'b0;
	 // 100ms debounce/repeat
	 if (interval_counter == 0) begin
            left_up_1d       <= left_up;
            left_down_1d     <= left_down;
            right_up_1d      <= right_up;
            right_down_1d    <= right_down;
            if (left_up && left_up_1d) begin
               left_up_pressed <= 1'b1;
            end
            if (left_down && left_down_1d) begin
               left_down_pressed <= 1'b1;
            end
            if (right_up && right_up_1d) begin
               right_up_pressed <= 1'b1;
            end
            if (right_down && right_down_1d) begin
               right_down_pressed <= 1'b1;
            end
	 end
      end
   end

   // paddle logic
   always @ (posedge clk) begin
      if (rst) begin
	 paddle_l_pos_v <= v_visible/2;
	 paddle_r_pos_v <= v_visible/2;
      end else begin
	 if (left_up_pressed && paddle_l_pos_v > paddle_size_v/2) begin
            paddle_l_pos_v <= paddle_l_pos_v - 1;
	 end
	 if (left_down_pressed && paddle_l_pos_v < v_visible - paddle_size_v/2) begin
            paddle_l_pos_v <= paddle_l_pos_v + 1;
	 end
	 if (right_up_pressed && paddle_r_pos_v > paddle_size_v/2) begin
            paddle_r_pos_v <= paddle_r_pos_v - 1;
	 end
	 if (right_down_pressed && paddle_r_pos_v < v_visible - paddle_size_v/2) begin
            paddle_r_pos_v <= paddle_r_pos_v + 1;
	 end
      end
   end

   // score pixels
   always @ (posedge clk) begin
      if (rst) begin
	 score_l_ten_enable <= 1'b0;
	 score_r_ten_enable <= 1'b0;
      end else begin
	 if (score_l > 9) begin
	    score_l_ten_enable <= 1'b1;
	 end else begin
	    score_l_ten_enable <= 1'b0;
	 end
	 if (score_r > 9) begin
	    score_r_ten_enable <= 1'b1;
	 end else begin
	    score_r_ten_enable <= 1'b0;
	 end
      end
      if (count_v == score_pos_v+0*score_unit-1) begin
	 // first row
	 case(score_l)
           0,10: score_l_unit_pixels       <= 3'b111;
           1,11: score_l_unit_pixels       <= 3'b010;
           2,12: score_l_unit_pixels       <= 3'b111;
           3,13: score_l_unit_pixels       <= 3'b111;
           4,14: score_l_unit_pixels       <= 3'b101;
           5,15: score_l_unit_pixels       <= 3'b111;
           6,16: score_l_unit_pixels       <= 3'b111;
           7,17: score_l_unit_pixels       <= 3'b111;
           8,18: score_l_unit_pixels       <= 3'b111;
	   default: score_l_unit_pixels <= 3'b111;
	 endcase
	 case(score_r)
           0,10: score_r_unit_pixels       <= 3'b111;
           1,11: score_r_unit_pixels       <= 3'b010;
           2,12: score_r_unit_pixels       <= 3'b111;
           3,13: score_r_unit_pixels       <= 3'b111;
           4,14: score_r_unit_pixels       <= 3'b101;
           5,15: score_r_unit_pixels       <= 3'b111;
           6,16: score_r_unit_pixels       <= 3'b111;
           7,17: score_r_unit_pixels       <= 3'b111;
           8,18: score_r_unit_pixels       <= 3'b111;
	   default: score_r_unit_pixels    <= 3'b111;
	 endcase
      end else if (count_v == score_pos_v+1*score_unit-1) begin
	 case(score_l)
           0,10: score_l_unit_pixels       <= 3'b101;
           1,11: score_l_unit_pixels       <= 3'b010;
           2,12: score_l_unit_pixels       <= 3'b001;
           3,13: score_l_unit_pixels       <= 3'b001;
           4,14: score_l_unit_pixels       <= 3'b101;
           5,15: score_l_unit_pixels       <= 3'b100;
           6,16: score_l_unit_pixels       <= 3'b100;
           7,17: score_l_unit_pixels       <= 3'b001;
           8,18: score_l_unit_pixels       <= 3'b101;
           default: score_l_unit_pixels    <= 3'b101;
	 endcase
	 case(score_r)
           0,10: score_r_unit_pixels       <= 3'b101;
           1,11: score_r_unit_pixels       <= 3'b010;
           2,12: score_r_unit_pixels       <= 3'b001;
           3,13: score_r_unit_pixels       <= 3'b001;
           4,14: score_r_unit_pixels       <= 3'b101;
           5,15: score_r_unit_pixels       <= 3'b100;
           6,16: score_r_unit_pixels       <= 3'b100;
           7,17: score_r_unit_pixels       <= 3'b001;
           8,18: score_r_unit_pixels       <= 3'b101;
	   default: score_r_unit_pixels    <= 3'b101;
	 endcase
      end else if (count_v == score_pos_v+2*score_unit-1) begin
	 case(score_l)
           0,10: score_l_unit_pixels       <= 3'b101;
           1,11: score_l_unit_pixels       <= 3'b010;
           2,12: score_l_unit_pixels       <= 3'b111;
           3,13: score_l_unit_pixels       <= 3'b111;
           4,14: score_l_unit_pixels       <= 3'b111;
           5,15: score_l_unit_pixels       <= 3'b111;
           6,16: score_l_unit_pixels       <= 3'b111;
           7,17: score_l_unit_pixels       <= 3'b001;
           8,18: score_l_unit_pixels       <= 3'b111;
           default: score_l_unit_pixels    <= 3'b111;
	 endcase
	 case(score_r)
           0,10: score_r_unit_pixels       <= 3'b101;
           1,11: score_r_unit_pixels       <= 3'b010;
           2,12: score_r_unit_pixels       <= 3'b111;
           3,13: score_r_unit_pixels       <= 3'b111;
           4,14: score_r_unit_pixels       <= 3'b111;
           5,15: score_r_unit_pixels       <= 3'b111;
           6,16: score_r_unit_pixels       <= 3'b111;
           7,17: score_r_unit_pixels       <= 3'b001;
           8,18: score_r_unit_pixels       <= 3'b111;
           default: score_r_unit_pixels    <= 3'b111;
	 endcase
      end else if (count_v == score_pos_v+3*score_unit-1) begin
	 case(score_l)
           0,10: score_l_unit_pixels       <= 3'b101;
           1,11: score_l_unit_pixels       <= 3'b010;
           2,12: score_l_unit_pixels       <= 3'b100;
           3,13: score_l_unit_pixels       <= 3'b001;
           4,14: score_l_unit_pixels       <= 3'b001;
           5,15: score_l_unit_pixels       <= 3'b001;
           6,16: score_l_unit_pixels       <= 3'b101;
           7,17: score_l_unit_pixels       <= 3'b001;
           8,18: score_l_unit_pixels       <= 3'b101;
           default: score_l_unit_pixels    <= 3'b001;
	 endcase
	 case(score_r)
           0,10: score_r_unit_pixels       <= 3'b101;
           1,11: score_r_unit_pixels       <= 3'b010;
           2,12: score_r_unit_pixels       <= 3'b100;
           3,13: score_r_unit_pixels       <= 3'b001;
           4,14: score_r_unit_pixels       <= 3'b001;
           5,15: score_r_unit_pixels       <= 3'b001;
           6,16: score_r_unit_pixels       <= 3'b101;
           7,17: score_r_unit_pixels       <= 3'b001;
           8,18: score_r_unit_pixels       <= 3'b101;
           default: score_r_unit_pixels    <= 3'b001;
	 endcase
      end else if (count_v == score_pos_v+4*score_unit-1) begin
	 case(score_l)
           0,10: score_l_unit_pixels       <= 3'b111;
           1,11: score_l_unit_pixels       <= 3'b010;
           2,12: score_l_unit_pixels       <= 3'b111;
           3,13: score_l_unit_pixels       <= 3'b111;
           4,14: score_l_unit_pixels       <= 3'b001;
           5,15: score_l_unit_pixels       <= 3'b111;
           6,16: score_l_unit_pixels       <= 3'b111;
           7,17: score_l_unit_pixels       <= 3'b001;
           8,18: score_l_unit_pixels       <= 3'b111;
           default: score_l_unit_pixels    <= 3'b001;
	 endcase
	 case(score_r)
           0,10: score_r_unit_pixels       <= 3'b111;
           1,11: score_r_unit_pixels       <= 3'b010;
           2,12: score_r_unit_pixels       <= 3'b111;
           3,13: score_r_unit_pixels       <= 3'b111;
           4,14: score_r_unit_pixels       <= 3'b001;
           5,15: score_r_unit_pixels       <= 3'b111;
           6,16: score_r_unit_pixels       <= 3'b111;
           7,17: score_r_unit_pixels       <= 3'b001;
           8,18: score_r_unit_pixels       <= 3'b111;
           default: score_r_unit_pixels    <= 3'b001;
	 endcase
      end
   end // score pixels
   
   // ball logic
   always @ (posedge clk) begin
      if (rst) begin
	 ball_pos_v    <= v_visible/2;
	 ball_pos_h    <= paddle_r_pos_h-1;
	 ball_motion_l <= 1'b1;
	 ball_angle    <= 4'b1001;
	 ball_ratio    <= 0;
	 score_l       <= 5'b0;
	 score_r       <= 5'b0;
      end else begin
	 if (score_reset == 1'b1) begin
            score_l <= 5'b0;
            score_r <= 5'b0;
	 end
	 if (interval_counter == 0) begin
            // is the ball moving left
            if (ball_motion_l == 1'b1) begin
               // is the ball in the left paddle column
               if (ball_pos_h == paddle_l_pos_h-1) begin
		  // did the ball hit the left paddle
		  if (ball_pos_v >= paddle_l_pos_v-paddle_size_v/2 && ball_pos_v <= paddle_l_pos_v+paddle_size_v/2) begin
		     // bounce off left paddle
		     ball_motion_l        <= 1'b0;
		  end else if (score_r != 19) begin
		     // right side serves
		     ball_pos_h         <= paddle_r_pos_h-1;
		     ball_pos_v         <= paddle_r_pos_v;
		     score_r            <= score_r + 1;
		     ball_angle         <= ball_angle + 3;  // "random"
		  end
               end else begin
		  // ball is moving left
		  ball_pos_h <= ball_pos_h-1;
		  // vertical motion
		  if (ball_angle[2:0] != 3'b000) begin
		     if (ball_ratio == ball_angle[2:0]) begin
			if (ball_angle[3] == 1'b1) begin
			   if (ball_pos_v < v_visible-1) begin
			      // moving down
			      ball_pos_v <= ball_pos_v+1;
			   end else begin
			      // bounce up
			      ball_angle[3] <= 1'b0;
			   end
			end else begin
			   // moving up
			   if (ball_pos_v != 0) begin
			      ball_pos_v <= ball_pos_v-1;
			   end else begin
			      // bounce down
			      ball_angle[3] <= 1'b1;
			   end
			end
			ball_ratio <= 0;
		     end else begin
			ball_ratio <= ball_ratio+1;
		     end
		  end
               end
            end else begin // if (ball_motion_l == 1'b1)
               // ball is moving right, is the ball in the right paddle column
               if (ball_pos_h == paddle_r_pos_h-1) begin
		  // did the ball hit the right paddle
		  if (ball_pos_v >= paddle_r_pos_v-paddle_size_v/2 && ball_pos_v <= paddle_r_pos_v+paddle_size_v/2) begin
		     // bounce off right paddle
		     ball_motion_l        <= 1'b1;
		  end else if (score_l != 19) begin
		     // left side serves
		     ball_pos_h <= paddle_l_pos_h-1;
		     ball_pos_v <= paddle_l_pos_v;
		     score_l    <= score_l + 1;
		     ball_angle <= ball_angle + 3;  // "random"
		  end
               end else begin
		  // ball is moving right
		  ball_pos_h <= ball_pos_h+1;
		  // vertical motion
		  if (ball_angle[2:0] != 3'b000) begin
		     if (ball_ratio == ball_angle[2:0]) begin
			if (ball_angle[3] == 1'b1) begin
			   if (ball_pos_v < v_visible-1) begin
			      // moving down
			      ball_pos_v <= ball_pos_v+1;
			   end else begin
			      // bounce up
			      ball_angle[3] <= 1'b0;
			   end
			end else begin
			   // moving up
			   if (ball_pos_v != 0) begin
			      ball_pos_v <= ball_pos_v-1;
			   end else begin
			      // bounce down
			      ball_angle[3] <= 1'b1;
			   end
			end
			ball_ratio <= 0;
		     end else begin
			ball_ratio <= ball_ratio+1;
		     end
		  end
               end
            end
	 end
      end
   end
endmodule
