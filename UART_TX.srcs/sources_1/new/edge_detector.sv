`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 01:34:31 PM
// Design Name: 
// Module Name: edge_detector
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


module edge_detector(
    input logic clk,
    input logic signal_in,
    output logic pulse
    );
    
    logic previous_signal;
    
    always_ff @(posedge clk) begin
        previous_signal <= signal_in;
    end
    
    assign pulse = !previous_signal && signal_in;
    
endmodule
