`timescale 1ns/1ps

module tb_bound_flasher();
  reg clk;
  reg rst_n;
  reg flick;
  wire [15:0] lamps;

  // Port connection by name [cite: 63, 64]
  bound_flasher dut (
    .clk(clk),
    .rst_n(rst_n),
    .flick(flick),
    .lamps(lamps)
  );

  // Clock generation: 100MHz
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Terminal Monitoring
  initial begin
    $display("Time(ns) | Flick | Lamps (L15 -> L0)");
    $display("---------------------------------------");
    $monitor("%8t |   %b   | %b", $time, flick, lamps);
  end

  initial begin
    // Reset system
    rst_n = 0;       
    flick = 0;
    #25 rst_n = 1;      
    #20;

    $display("--- Starting Normal Flow ---");
    @(posedge clk);
    flick = 1;       // Flick
    @(posedge clk);
    flick = 0;
    
    // Đợi đèn quay về trạng thái ban đầu
    wait(dut.state == 3'd0 && lamps == 16'h0000);
    #100;

    $display("--- Starting Kickback Test at LED 5 ---");
    @(posedge clk);
    flick = 1; 
    @(posedge clk);
    flick = 0;
    
    // Đợi đến lúc đèn số 5 sáng ở chu kỳ UP_0_10
    wait(dut.state == 3'd3 && lamps[5] == 1'b1);
    
    @(posedge clk);
    flick = 1; // Nhấn flick tại điểm kickback
    @(posedge clk);     
    flick = 0;

    #1000;
    $display("Simulation Finished");
    $finish;
  end
initial begin
        $recordfile("waves");
        $recordvars("depth=0", tb_bound_flasher);
end
endmodule
