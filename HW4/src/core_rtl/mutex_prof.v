`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/04 00:57:08
// Design Name: 
// Module Name: mutex_prof
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//  This module counts the cycles spent on mutex operation.
//  Both set-and-test and semaphore mutex are included.
//  But beware of that relocation problem since we use two files.
//  Counting for:
//      initialize, take, give.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "aquila_config.vh"

module mutex_prof
#(
    parameter CNT_BITS = 64,
    parameter XLEN     = 32
)(
    // system input
    input clk_i,
    input rst_i,
    
    // input
    input  [XLEN-1 : 0] pc_i   // we use the fetch stage pc
    
    //output, no ouput yet
    
    );
//==========================================================
// localparam
//
localparam [XLEN-1 : 0]
    mutex_init_s  = 32'h80002c24,
    mutex_init_e  = 32'h80002c88,
    mutex_take_s1 = 32'h80001168, // jal take
    mutex_take_s2 = 32'h80001068, // jal take
    mutex_take_e1 = 32'h8000116c, // lw
    mutex_take_e2 = 32'h8000106c, // lw
    mutex_give_s1 = 32'h80001190, // jal send
    mutex_give_s2 = 32'h80001090, // jal send
    mutex_give_e1 = 32'h80001194, // bgez
    mutex_give_e2 = 32'h80001094; // li
//
// end of localparam
//==========================================================
//==========================================================
// wires and registers
// 
wire [XLEN-1 : 0] pc;

wire enter_mutex_init, exit_mutex_init,
     enter_mutex_take, exit_mutex_take,
     enter_mutex_give, exit_mutex_give;
     
reg  in_mutex_init, in_mutex_take, in_mutex_give;

(* mark_debug = "true" *) reg [CNT_BITS-1 : 0]
     mutex_init_cnt, mutex_init_ltc,
     mutex_take_cnt, mutex_take_ltc,
     mutex_give_cnt, mutex_give_ltc;
//
// end of wires and registers
//==========================================================
//==========================================================
// wires and registers assign
// wires: pc
assign pc = pc_i;

// wires: entering and exiting signals
assign enter_mutex_init = (pc == mutex_init_s);
assign exit_mutex_init  = (pc == mutex_init_e);
assign enter_mutex_take = (pc == mutex_take_s1 | pc == mutex_take_s2);
assign exit_mutex_take  = (pc == mutex_take_e1 | pc == mutex_take_e2);
assign enter_mutex_give = (pc == mutex_give_s1 | pc == mutex_give_s2);
assign exit_mutex_give  = (pc == mutex_give_e1 | pc == mutex_give_e2);

// regs: in signals
// mutex init
always @(posedge clk_i)
begin
    if (rst_i) in_mutex_init <= 1'b0;
    else if (enter_mutex_init) in_mutex_init <=1'b1;
    else if (exit_mutex_init) in_mutex_init <= 1'b0;
    else in_mutex_init <= in_mutex_init;    
end

// mutex take
always @(posedge clk_i)
begin
    if (rst_i) in_mutex_take <= 1'b0;
    else if (enter_mutex_take) in_mutex_take <= 1'b1;
    else if (exit_mutex_take) in_mutex_take <= 1'b0;
    else in_mutex_take <= in_mutex_take;
end

// mutex give
always @(posedge clk_i)
begin
    if (rst_i) in_mutex_give <= 2'b00;
    else if (enter_mutex_give) in_mutex_give <= 1'b1;
    else if (exit_mutex_give) in_mutex_give <= 1'b0;
    else in_mutex_give <= in_mutex_give;
end

// regs: count and latency
// mutex init
always @(posedge clk_i)
begin
    if (rst_i) mutex_init_cnt <= 0;
    else if (enter_mutex_init & ~in_mutex_init)
        mutex_init_cnt <= mutex_init_cnt + 1;
    else mutex_init_cnt <= mutex_init_cnt; 
end

always @(posedge clk_i)
begin
    if (rst_i) mutex_init_ltc <= 0;
    else if (in_mutex_init)
        mutex_init_ltc <= mutex_init_ltc + 1;
    else mutex_init_ltc <= mutex_init_ltc;
end

// mutex take
always @(posedge clk_i)
begin
    if (rst_i) mutex_take_cnt <= 0;
    else if (enter_mutex_take & ~in_mutex_take)
        mutex_take_cnt <= mutex_take_cnt + 1;
    else mutex_take_cnt <= mutex_take_cnt; 
end

always @(posedge clk_i)
begin
    if (rst_i) mutex_take_ltc <= 0;
    else if (in_mutex_take)
        mutex_take_ltc <= mutex_take_ltc + 1;
    else mutex_take_ltc <= mutex_take_ltc;
end

// mutex give
always @(posedge clk_i)
begin
    if (rst_i) mutex_give_cnt <= 0;
    else if (enter_mutex_give & ~in_mutex_give)
        mutex_give_cnt <= mutex_give_cnt + 1;
    else mutex_give_cnt <= mutex_give_cnt; 
end

always @(posedge clk_i)
begin
    if (rst_i) mutex_give_ltc <= 0;
    else if (in_mutex_give)
        mutex_give_ltc <= mutex_give_ltc + 1;
    else mutex_give_ltc <= mutex_give_ltc;
end

endmodule
