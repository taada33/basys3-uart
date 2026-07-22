`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: uart_tx
// Description:
//   UART transmitter, 8-N-1 format
//
// Parameters:
//   BAUD_RATE : UART baud rate
//   CLK_FREQ  : FPGA clock frequency
//
// Interface:
//   tx_start : 1-cycle transmit request
//   parallel : byte to transmit
//   serial   : UART TX output
//
// Notes:
//   - LSB first transmission
//   - 1 start bit
//   - 8 data bits
//   - 1 stop bit
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx #(
    parameter int BAUD_RATE = 9600,
    parameter int CLK_FREQ = 100_000_000
    )(
    input logic clk,
    input logic tx_start,
    input logic reset,
    input logic [7:0] parallel,
    output logic serial
    );
    
    localparam int CYCLES = CLK_FREQ/BAUD_RATE;
    
    
    logic [$clog2(CYCLES)-1:0] counter;
    logic [7:0] shift_reg;
    logic [3:0] bit_count;
    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;
    state_t state;
    
   
    //FSM logic
    always_ff @(posedge clk) begin
        if(reset) begin
            state <= IDLE;
            bit_count <= 0;
            shift_reg <= 0;
        end else if(tx_start && state == IDLE) begin
                state <= START;
                shift_reg <= parallel;     
                bit_count <= 0;
        end else if(counter == CYCLES-1) begin
            if(state == START) begin
                state <= DATA;
            end else if(state == DATA) begin
                if(bit_count == 7) begin
                state <= STOP;
                end else begin
                    bit_count <= bit_count + 1;
                    shift_reg <= shift_reg >> 1;
                end
            end else if(state == STOP) begin
                state <= IDLE;
                shift_reg <= 0;
            end else begin
                state <= IDLE;
            end            
        end
    end
    
    
    //counter logic
    always_ff @(posedge clk) begin
        if(reset) begin
            counter <= 0;
        end else if(state == IDLE) begin
            counter <= 0;
        end else if(counter == CYCLES-1) begin
            counter <= 0;
        end else begin
            counter <= counter +1;
        end
    end
    
    
    //serial output logic
    always_comb begin
        case(state)
            IDLE:  serial = 1'b1;
            START: serial = 1'b0;
            DATA:  serial = shift_reg[0];
            STOP:  serial = 1'b1;
            default: serial = 1'b1;
        endcase
    end
    
            
endmodule
