# UART Transmitter (SystemVerilog)

A parameterized UART transmitter designed in SystemVerilog for the Digilent Basys 3 FPGA.

## Features

- 8-N-1 UART transmission
- Configurable baud rate
- Configurable clock frequency
- Push-button debouncing
- Self-checking SystemVerilog testbench
- Top-level integration testbench
- Successfully simulated in Vivado
- Successfully synthesized for Basys 3

## Project Structure

UART_TX.srcs/
* sources_1/
  * debouncer.sv
  * edge_detector.sv
  * seven_seg.sv
  * uart_tx.sv
  * top.sv
* sim_1/
  * tb_top.sv
  * tb_uart_tx.sv
* constrs_1/
  * Basys-3-Master.xdc 

## Hardware

- Digilent Basys 3
- 100 MHz system clock
- Eight switches used as the transmit byte
- Center push button used to initiate transmission
- UART output connected to the onboard USB-UART interface

## Future Work

- UART Receiver
- TX/RX loopback
- PC serial communication
