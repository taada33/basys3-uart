`timescale 1ns / 1ps

module tb_uart_tx;

  localparam int baud_rate = 9600;
  localparam int clk_freq  = 100_000_000;
  localparam int cycles    = clk_freq/baud_rate;

  logic clk = 0;
  always #5 clk = ~clk; // 100 MHz => 10ns period (adjust if needed)

  logic tx_start;
  logic reset;
  logic [7:0] parallel;
  logic serial;

  uart_tx #(
    .BAUD_RATE(baud_rate),
    .CLK_FREQ(clk_freq)
  ) dut (
    .clk(clk),
    .tx_start(tx_start),
    .reset(reset),
    .parallel(parallel),
    .serial(serial)
  );

  task automatic wait_clocks(input int n);
    repeat (n) @(posedge clk);
  endtask

  task automatic send_and_check(input [7:0] data);
    int i;
    logic [7:0] received;
    int half = cycles/2;

    // idle
    tx_start  = 1'b0;
    parallel  = data;

    // Start request (pulse)
    @(posedge clk);
    tx_start <= 1'b1;
    @(posedge clk);
    tx_start <= 1'b0;

    // Verify we're in the middle of the start bit.
    wait_clocks(half);
    assert(serial == 1'b0);
    
    // Move to the middle of the first data bit.
    wait_clocks(cycles);

    received = '0;
    for (i = 0; i < 8; i++) begin
      received[i] = serial;     // mid-bit sample
      wait_clocks(cycles);     // next mid-bit
    end

    // Now mid-bit of STOP
    wait_clocks(half);
    if (serial !== 1'b1) begin
      $error("STOP bit error: expected 1, got %0b", serial);
    end

    if (received !== data) begin
      $error("DATA mismatch: expected 0x%0h got 0x%0h", data, received);
    end else begin
      $display("PASS: data=0x%0h", data);
    end
  endtask


  initial begin
    // Init
    reset     = 1'b1;
    tx_start  = 1'b0;
    parallel  = 8'h00;

    // Hold reset for a few clocks
    repeat (5) @(posedge clk);
    reset = 1'b0;

    // Wait a bit, then test vectors
    repeat (20) @(posedge clk);

    send_and_check(8'hAA);
    send_and_check(8'hA5);
    send_and_check(8'hFF);
    send_and_check(8'h3C);

    $display("All tests done.");
    $finish;
  end

endmodule
