// module bound_flasher (
//   input clk,
//   input rst_n,
//   input flick,
//   output reg [15:0] lamps
// );

//   localparam IDLE      = 3'd0,
//              UP_0_5    = 3'd1,
//              DOWN_5_0  = 3'd2,
//              UP_0_10   = 3'd3,
//              DOWN_10_5 = 3'd4,
//              UP_5_15   = 3'd5,
//              DOWN_15_0 = 3'd6;

//   reg [2:0] state;
//   reg [4:0] i;

//   always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//       state <= IDLE;
//       lamps <= 16'h0000;
//       i     <= 5'd0;
//     end else begin
//       case (state)
//         IDLE: begin
//           if (flick) begin
//             state <= UP_0_5;
//             lamps <= 16'h0001;
//             i     <= 5'd0;
//           end else begin
//             lamps <= 16'h0000;
//           end
//         end

//         UP_0_5: begin
//           if (i == 5'd5) begin
//             state <= DOWN_5_0;
//           end else begin
//             i <= i + 5'd1;
//             lamps[i + 5'd1] <= 1'b1;
//           end
//         end

//         DOWN_5_0: begin
//           if (i == 5'd0 && lamps[0] == 1'b0) begin
//             state <= UP_0_10;
//             i <= 5'd0;
//             lamps[0] <= 1'b1;
//           end else begin
//             lamps[i] <= 1'b0;
//             if (i > 5'd0) i <= i - 5'd1;
//           end
//         end

//         UP_0_10: begin
//           // Kickback tại 5
//           if (i == 5'd5 && flick) begin
//             state <= DOWN_5_0;
//             lamps[5] <= 1'b0;
//             i <= 5'd4;
//           end else if (i == 5'd10) begin
//             state <= DOWN_10_5; 
//           end else begin
//             i <= i + 5'd1;
//             lamps[i + 5'd1] <= 1'b1;
//           end
//         end

//         DOWN_10_5: begin
//           if (i == 5'd5 && lamps[5] == 1'b1) begin
//             state <= UP_5_15;
//           end else begin
//             lamps[i] <= 1'b0;
//             if (i > 5'd5) i <= i - 5'd1;
//           end
//         end

//         UP_5_15: begin
//           // Kickback tại 10
//           if (i == 5'd10 && flick) begin
//             state <= DOWN_10_5;
//             lamps[10] <= 1'b0;
//             i <= 5'd9;
//           end else if (i == 5'd15) begin
//             state <= DOWN_15_0;
//           end else begin
//             i <= i + 5'd1;
//             lamps[i + 5'd1] <= 1'b1;
//           end
//         end

//         DOWN_15_0: begin
//           if (i == 5'd0 && lamps[0] == 1'b0) begin
//             state <= IDLE;
//           end else begin
//             lamps[i] <= 1'b0;
//             if (i > 5'd0) i <= i - 5'd1;
//           end
//         end

//         default: state <= IDLE;
//       endcase
//     end
//   end

// endmodule


module bound_flasher (
  input wire clk,
  input wire rst_n,
  input wire flick,
  output wire [15:0] lamps
);

  localparam IDLE      = 3'd0,
             UP_0_5    = 3'd1,
             DOWN_5_0  = 3'd2,
             UP_0_10   = 3'd3,
             DOWN_10_5 = 3'd4,
             UP_5_15   = 3'd5,
             DOWN_15_0 = 3'd6;

  reg [2:0] state;
  reg [4:0] i;
  
  // Mảng đệm 32-bit để thỏa mãn không gian địa chỉ của index 5-bit (tránh RTL7.4)
  reg [31:0] lamps_full; 

  // Chỉ lấy 16-bit có ý nghĩa đẩy ra output. 16-bit cao sẽ bị tool tổng hợp tự động cắt bỏ.
  assign lamps = lamps_full[15:0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state      <= IDLE;
      lamps_full <= 32'h0000_0000;
      i          <= 5'd0;
    end else begin
      case (state)
        IDLE: begin
          if (flick) begin
            state      <= UP_0_5;
            lamps_full <= 32'h0000_0001;
            i          <= 5'd0;
          end else begin
            lamps_full <= 32'h0000_0000;
          end
        end

        UP_0_5: begin
          if (i == 5'd5) begin
            state <= DOWN_5_0;
          end else begin
            // Dùng bit-mask & 5'h1F để ép kiểu về chuẩn 5-bit, tránh warning RTL1.5b/c
            i <= (i + 1'b1) & 5'h1F;
            lamps_full[(i + 1'b1) & 5'h1F] <= 1'b1;
          end
        end

        DOWN_5_0: begin
          if (i == 5'd0 && lamps_full[0] == 1'b0) begin
            state <= UP_0_10;
            i <= 5'd0;
            lamps_full[0] <= 1'b1;
          end else begin
            lamps_full[i] <= 1'b0;
            if (i > 5'd0) i <= (i - 1'b1) & 5'h1F;
          end
        end

        UP_0_10: begin
          if (i == 5'd5 && flick) begin
            state <= DOWN_5_0;
            lamps_full[5] <= 1'b0;
            i <= 5'd4;
          end else if (i == 5'd10) begin
            state <= DOWN_10_5; 
          end else begin
            i <= (i + 1'b1) & 5'h1F;
            lamps_full[(i + 1'b1) & 5'h1F] <= 1'b1;
          end
        end

        DOWN_10_5: begin
          if (i == 5'd5 && lamps_full[5] == 1'b1) begin
            state <= UP_5_15;
          end else begin
            lamps_full[i] <= 1'b0;
            if (i > 5'd5) i <= (i - 1'b1) & 5'h1F;
          end
        end

        UP_5_15: begin
          if (i == 5'd10 && flick) begin
            state <= DOWN_10_5;
            lamps_full[10] <= 1'b0;
            i <= 5'd9;
          end else if (i == 5'd15) begin
            state <= DOWN_15_0;
          end else begin
            i <= (i + 1'b1) & 5'h1F;
            lamps_full[(i + 1'b1) & 5'h1F] <= 1'b1;
          end
        end

        DOWN_15_0: begin
          if (i == 5'd0 && lamps_full[0] == 1'b0) begin
            state <= IDLE;
          end else begin
            lamps_full[i] <= 1'b0;
            if (i > 5'd0) i <= (i - 1'b1) & 5'h1F;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule