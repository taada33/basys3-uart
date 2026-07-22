`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 02:29:41 PM
// Design Name: 
// Module Name: tb_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_top;

    localparam int BAUD_RATE     = 9600;
    localparam int CLK_FREQ      = 100_000_000;
    localparam int DEBOUNCE_FREQ = 10_000_000;

    localparam int CYCLES = CLK_FREQ / BAUD_RATE;

    logic clk = 0;
    always #5 clk = ~clk; // 100 MHz => 10ns period (adjust if needed)
    
    logic reset;
    logic btnC;
    logic [7:0] sw;
    logic uart_txd;
    
    top #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ),
        .DEBOUNCE_FREQ(DEBOUNCE_FREQ)
    ) dut (
    .clk(clk),
    .reset(reset),
    .btnC(btnC),
    .sw(sw),
    .uart_txd(uart_txd)
    );
    
    task automatic wait_clocks(input int n);
        repeat (n) @(posedge clk);
    endtask
    
    task automatic send_and_check(input [7:0] data);
    
        logic [7:0] received;
        
        //idle
        btnC = 1'b0;
        sw = data;
        
        //Start Request
        @(posedge clk);
        btnC = 1'b1;

        @(negedge uart_txd);
        btnC = 1'b0;
        //Wait half UART bit period to be in middle of start bit
        wait_clocks(CYCLES/2);
        assert(uart_txd === 1'b0)
            else $error("START bit error: expected 0, got %0b", uart_txd);
        //Receive Data
        wait_clocks(CYCLES);
        received = '0;
        for(int i = 0; i<8; i++) begin
            received[i] = uart_txd;
            wait_clocks(CYCLES);
        end
        //Check Stop bit
        if (uart_txd !== 1'b1) begin
          $error("STOP bit error: expected 1, got %0b", uart_txd);
        end
        //Compare received vs. sent
        if (received !== data) begin
          $error("DATA mismatch: expected 0x%0h got 0x%0h", data, received);
        end else begin
          $display("PASS: data=0x%0h", data);
        end
        
        wait_clocks(CYCLES*3);
    endtask
    
    initial begin
    
        $display("Running tb_top");
        // Init
        reset = 1'b1;
        btnC = 1'b0;
        sw = 8'h00;
    
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
