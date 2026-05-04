module bound_flasher (
  input clk,
  input rst_n,
  input flick,
  output reg [15:0] lamps
);

  localparam IDLE      = 3'd0,
             UP_0_5    = 3'd1,
             DOWN_5_0  = 3'd2,
             UP_0_10   = 3'd3,
             DOWN_10_5 = 3'd4,
             UP_5_15   = 3'd5,
             DOWN_15_0 = 3'd6;

  reg [3:0] state;
  integer i; 

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      lamps <= 16'h0000;
      i     <= 0;
    end else begin
      case (state)
        IDLE: begin
          if (flick) begin
            state <= UP_0_5;
            lamps <= 16'h0001;
            i     <= 0;
          end else begin
            lamps <= 16'h0000;
          end
        end

        UP_0_5: begin
          if (i == 5) begin
            state <= DOWN_5_0;
          end else begin
            i <= i + 1;
            lamps[i + 1] <= 1'b1;
          end
        end

        DOWN_5_0: begin
          if (i == 0 && lamps[0] == 1'b0) begin
            state <= UP_0_10;
            i <= 0;
            lamps[0] <= 1'b1;
          end else begin
            lamps[i] <= 1'b0;
            if (i > 0) i <= i - 1;
          end
        end

        UP_0_10: begin
          // Kickback tại 5
          if (i == 5 && flick) begin
            state <= DOWN_5_0;
            lamps[5] <= 1'b0;
            i <= 4;
          end else if (i == 10) begin
            state <= DOWN_10_5; // Đạt đèn 10 
          end else begin
            i <= i + 1;
            lamps[i + 1] <= 1'b1;
          end
        end

        DOWN_10_5: begin
          if (i == 5 && lamps[5] == 1'b1) begin
            state <= UP_5_15;
          end else begin
            lamps[i] <= 1'b0;
            if (i > 5) i <= i - 1;
          end
        end

        UP_5_15: begin
          // Kickback tại 10
          if (i == 10 && flick) begin
            state <= DOWN_10_5;
            lamps[10] <= 1'b0;
            i <= 9;
          end else if (i == 15) begin
            state <= DOWN_15_0;
          end else begin
            i <= i + 1;
            lamps[i + 1] <= 1'b1;
          end
        end

        DOWN_15_0: begin
          if (i == 0 && lamps[0] == 1'b0) begin
            state <= IDLE;
          end else begin
            lamps[i] <= 1'b0;
            if (i > 0) i <= i - 1;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
