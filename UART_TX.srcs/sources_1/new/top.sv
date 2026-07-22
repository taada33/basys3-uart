`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2026 07:13:43 PM
// Design Name: 
// Module Name: top
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


module top #(
    parameter int BAUD_RATE = 9600,
    parameter int CLK_FREQ = 100_000_000,
    parameter int DEBOUNCE_FREQ = 125,
    parameter int REFRESH_HZ = 2000
    )(
    input clk,
    input reset,
    input btnC,
    input [7:0] sw,
    output [6:0] seg,
    output [3:0] an,
    output uart_txd
    );
    
    logic signal_sync, signal_debounced, signal_pulse;
    
    uart_tx #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uart_tx_inst (
        .clk(clk),
        .tx_start(signal_pulse),
        .reset(reset),
        .parallel(sw),
        .serial(uart_txd)
    );
    
   seven_seg #(
        .REFRESH_HZ(REFRESH_HZ),
        .CLK_FREQ(CLK_FREQ)
   ) seven_seg_inst (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .seg(seg),
        .an(an)
   );
   
   synchronizer synchronizer_inst (
        .clk(clk),
        .reset(reset),
        .signal_in(btnC),
        .signal_out(signal_sync)
   );
   
   debouncer #(
        .CLK_FREQ(CLK_FREQ),
        .DEBOUNCE_FREQ(DEBOUNCE_FREQ)
   ) debouncer_inst (
        .clk(clk),
        .reset(reset),
        .signal_in(signal_sync),
        .signal_out(signal_debounced)
   );
   
   edge_detector edge_detector_inst (
        .clk(clk),
        .signal_in(signal_debounced),
        .pulse(signal_pulse)
   );
        
endmodule
