`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 01:34:31 PM
// Design Name: 
// Module Name: synchronizer
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


module synchronizer(
    input logic clk,
    input logic reset,
    input logic signal_in,
    output logic signal_out
    );
    
    logic ff1, ff2;
    
    always_ff @(posedge clk) begin
        if(reset) begin
            ff1 <= 0;
            ff2 <= 0;
        end else begin
            ff1 <= signal_in;
            ff2 <= ff1;
        end
    end
    
    assign signal_out = ff2;
    
    
endmodule
