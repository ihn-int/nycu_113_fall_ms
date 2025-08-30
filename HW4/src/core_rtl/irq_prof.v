`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/01 14:39:22
// Design Name: 
// Module Name: irq_prof
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:
//  This module counts the number and latency of: 
//      freertos_risc_v_trap_handler
//      xTaskIncrementTick
//      vTaskSwitchContext
//      processed_source
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "aquila_config.vh"

module irq_prof
#(
    parameter CNT_BITS = 64,
    parameter XLEN     = 32
)(
    // system input
    input clk_i,
    input rst_i,
    
    // input
    input  [XLEN-1 : 0] pc_i,  // we use the fetch stage pc
    input  timer_irq_i,
    
    //output
    output is_working_o
    );
//==========================================================
// localparam
// for trap handler
localparam [XLEN-1 : 0]
    working_s  = 32'h80004ed0, // enter of scheduler
        // the csrw instruction
    working_e1 = 32'h80001314, // delete task 1
    working_e2 = 32'h800010e4, // delete task 2
    trap_handler_s   = 32'h80007200, // enter of trap handler
    trap_handler_e   = 32'h800073e8, // address of mret
    task_increment_s = 32'h800072f8, // call of task increment
    task_increment_e = 32'h800072fc, // next instr of task increment
    switch_context_s = 32'h80007300, // enter of switch context
    switch_context_e = 32'h80007304; // next instr of switch context
// Trap handler is used to count the overhead of context
// switch, while others arer used to count the latency of
// single section.
//
// end of localparam
// =========================================================

// =========================================================
// wires and registers declare
//
wire [XLEN-1 : 0] pc;
wire task_1_end, task_2_end;
wire is_working;

// we use register as flag to determine it's working or not
reg  in_trap_handler, in_handle_async, in_task_increment,
     in_switch_context, in_process_source, in_irq;
reg  [1 : 0] working_flag;

(* mark_debug = "true" *) reg  [CNT_BITS-1 : 0]
    trap_handler_cnt, trap_handler_ltc,
    task_increment_cnt, task_increment_ltc,
    switch_context_cnt, switch_context_ltc,
    irq_cnt, irq_ltc;
//
// end of wires and registers declare
//==========================================================

//==========================================================
// wire and register assign
// wires
assign pc = pc_i;
assign task_1_end = (pc == working_e1);
assign task_2_end = (pc == working_e2);
assign is_working = (^(working_flag)); // & (~stall_i);
assign is_working_o = is_working;

// working signal regsiters
// we count from scheduler start and two task are deleted
// we put state transfer logic in here
always @(posedge clk_i)
begin
    if (rst_i) working_flag <= 2'b00;
    else case(working_flag)
        2'b00: working_flag <= (pc == working_s) ? 2'b01 : 2'b00;
        2'b01: working_flag <= (task_1_end | task_2_end) ? 2'b10 : 2'b01;
        2'b10: working_flag <= (task_1_end | task_2_end) ? 2'b11 : 2'b10;
        2'b11: working_flag <= 2'b11;
        default: working_flag <= 2'b00;
    endcase
end 

// flag signal regsiters
// trap handler
always @(posedge clk_i)
begin
    if (rst_i) in_trap_handler <= 1'b0;
    else if (pc == trap_handler_s & is_working)
        in_trap_handler <= 1'b1;
    else if (pc == trap_handler_e | ~is_working)
        in_trap_handler <= 1'b0;
    else in_trap_handler <= in_trap_handler;
end

// task increment tick
always @(posedge clk_i)
begin
    if (rst_i) in_task_increment <= 1'b0;
    else if (pc == task_increment_s & is_working)
        in_task_increment <= 1'b1;
    else if (pc == task_increment_e | ~is_working)
        in_task_increment <= 1'b0;
    else in_task_increment <= in_task_increment;
end

// switch context
always @(posedge clk_i)
begin
    if (rst_i) in_switch_context <= 1'b0;
    else if (pc == switch_context_s & is_working)
        in_switch_context <= 1'b1;
    else if (pc == switch_context_e | ~is_working)
        in_switch_context <= 1'b0;
    else in_switch_context <= in_switch_context;
end

// irq
always @(posedge clk_i)
begin
    if (rst_i) in_irq <= 0;
    else if (timer_irq_i & is_working) in_irq <= 1;
    else if (pc == trap_handler_e | ~is_working) in_irq <= 0;
    else in_irq <= in_irq;
end

// counter and latency
// update counter whenever enter the section
// update latency whenever the flag is asserted
// trap handler
always @(posedge clk_i)
begin
    if (rst_i) trap_handler_cnt <= 0;
    else if (pc == trap_handler_s & ~in_trap_handler & is_working)
        trap_handler_cnt <= trap_handler_cnt + 1;
    else trap_handler_cnt <= trap_handler_cnt;
end

always @(posedge clk_i)
begin
    if (rst_i) trap_handler_ltc <= 0;
    else if (in_trap_handler)
        trap_handler_ltc <= trap_handler_ltc + 1;
    else trap_handler_ltc <= trap_handler_ltc; 
end

// task increment tick
always @(posedge clk_i)
begin
    if (rst_i) task_increment_cnt <= 0;
    else if (pc == task_increment_s & ~in_task_increment & is_working)
        task_increment_cnt <= task_increment_cnt + 1;
    else task_increment_cnt <= task_increment_cnt;
end

always @(posedge clk_i)
begin
    if (rst_i) task_increment_ltc <= 0;
    else if (in_task_increment)
        task_increment_ltc <= task_increment_ltc + 1;
    else task_increment_ltc <= task_increment_ltc; 
end

// switch context
always @(posedge clk_i)
begin
    if (rst_i) switch_context_cnt <= 0;
    else if (pc == switch_context_s & ~in_switch_context & is_working)
        switch_context_cnt <= switch_context_cnt + 1;
    else switch_context_cnt <= switch_context_cnt;
end

always @(posedge clk_i)
begin
    if (rst_i) switch_context_ltc <= 0;
    else if (in_switch_context)
        switch_context_ltc <= switch_context_ltc + 1;
    else switch_context_ltc <= switch_context_ltc; 
end

// irq
always @(posedge clk_i)
begin
    if (rst_i) irq_cnt <= 0;
    else if (timer_irq_i & ~in_irq & is_working) irq_cnt <= irq_cnt + 1;
    else irq_cnt <= irq_cnt;
end

always @(posedge clk_i)
begin
    if (rst_i) irq_ltc <= 0;
    else if (in_irq) irq_ltc <= irq_ltc + 1;
    else irq_ltc <= irq_ltc;
end
//
// end of wire and register assign
//==========================================================


endmodule