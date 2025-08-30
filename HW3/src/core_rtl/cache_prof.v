`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/09 13:35:04
// Design Name: 
// Module Name: cache_prof
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

module cache_prof #(
    parameter XLEN = 32,
    parameter CNT_BITS = 32
)(
    // system input
    input           clk_i,
    input           rst_i,
    
    // processor signals
    input           p_rw_i,
    input           p_strobe_i,
    input [XLEN-1 : 0] p_exepc_i,
    
    // cache signals
    input           c_ready_i,
    input           c_cache_hit_i,
    input  [3 : 0]  c_state_i
    );
    
//==========================================================
// localparam
//
// parameter for pi
/** / // For simulation
localparam ENTER_POINT = 32'h8000_16d0, // crt0 start
           END_POINT   = 32'h8000_16fc; // crt0 end
/**/
localparam ENTER_POINT = 32'h8000_1800,
           END_POINT   = 32'h8000_182c;

// parameter for Dcahce FSM
localparam Init             = 0, 
           Idle             = 1,
           Analysis         = 2,
           WbtoMem          = 3,
           WbtoMemFinish    = 4,
           RdfromMem        = 5,
           RdfromMemFinish  = 6,
           WbtoMemAll       = 7,
           WbtoMemAllFinish = 8,
           RdAmo            = 9,
           RdAmoFinish      = 10;

//
// end of localparam
//==========================================================

//==========================================================
// wires and regs
//
(* mark_debug = "true" *)
reg [CNT_BITS-1 : 0]
    // processor side
    pread_hit_num,  pread_miss_num,  pread_miss_ltc,
    pwrite_hit_num, pwrite_miss_num, pwrite_miss_ltc,
    mread_num,  mread_ltc,
    mwrite_num, mwrite_ltc;
reg is_reading, is_writing;

wire cache_hit, cache_miss;
wire is_working;
wire is_read_mem, is_write_mem;
wire is_reading_mem, is_writing_mem;
reg in_read_miss, in_write_miss;

assign cache_hit = (c_state_i == Analysis) && (c_cache_hit_i);
assign cache_miss = (c_state_i == Analysis) && (~c_cache_hit_i);
assign is_working = (p_exepc_i[31:28] == 4'h8);
assign is_read_mem = (c_state_i == RdfromMemFinish);
assign is_reading_mem = (c_state_i == RdfromMem | 
                         c_state_i == RdfromMemFinish);
assign is_write_mem = (c_state_i == WbtoMemFinish);
assign is_writing_mem = (c_state_i == WbtoMem | 
                         c_state_i == WbtoMemFinish);
//
// end of wires and regs
//==========================================================

//==========================================================
// flags
//
// These two flags should be synchronized to cache controller signals
always @(posedge clk_i) begin
    if (rst_i) is_reading <= 0;
    else if (p_strobe_i & ~p_rw_i) is_reading <= 1;
    else if (c_ready_i) is_reading <= 0;
    else is_reading <= is_reading;
end

always @(posedge clk_i) begin
    if (rst_i) is_writing <= 0;
    else if (p_strobe_i & p_rw_i) is_writing <= 1;
    else if (c_ready_i) is_writing <= 0;
    else is_writing <= is_writing;
end

always @(posedge clk_i) begin
    if (rst_i) in_read_miss <= 0;
    else if (is_reading & cache_miss)
        in_read_miss <= 1;
    else if (c_ready_i)
        in_read_miss <= 0;
    else in_read_miss <= in_read_miss;
end

always @(posedge clk_i) begin
    if (rst_i) in_write_miss <= 0;
    else if (is_writing & cache_miss)
        in_write_miss <= 1;
    else if (c_ready_i)
        in_write_miss <= 0;
    else in_write_miss <= in_write_miss;
end
//
// end of flags
//==========================================================

//==========================================================
// counters
//
// processor side
// processor read hit number
always @(posedge clk_i) begin
    if (rst_i) pread_hit_num <= 'd0;
    else if (is_working & is_reading & cache_hit)
        pread_hit_num <= pread_hit_num + 1;
    else pread_hit_num <= pread_hit_num;
end

// processor write hit number
always @(posedge clk_i) begin
    if (rst_i) pwrite_hit_num <= 'd0;
    else if (is_working & is_writing & cache_hit)
        pwrite_hit_num <= pwrite_hit_num + 1;
    else pwrite_hit_num <= pwrite_hit_num;
end

// processor read miss number
always @(posedge clk_i) begin
    if (rst_i) pread_miss_num <= 'd0;
    else if (is_working & is_reading & cache_miss)
        pread_miss_num <= pread_miss_num + 1;
    else pread_miss_num <= pread_miss_num;
end

// processor read miss latency
always @(posedge clk_i) begin
    if (rst_i) pread_miss_ltc <= 'd0;
    else if (is_working & in_read_miss)
        pread_miss_ltc <= pread_miss_ltc + 1;
    else pread_miss_ltc <= pread_miss_ltc;
end

// processor write miss number
always @(posedge clk_i) begin
    if (rst_i) pwrite_miss_num <= 'd0;
    else if (is_working & is_writing & cache_miss)
        pwrite_miss_num <= pwrite_miss_num + 1;
    else pwrite_miss_num <= pwrite_miss_num;
end

// processor write miss latency
always @(posedge clk_i) begin
    if (rst_i) pwrite_miss_ltc <= 'd0;
    else if (is_working & in_write_miss)
        pwrite_miss_ltc <= pwrite_miss_ltc + 1;
    else pwrite_miss_ltc <= pwrite_miss_ltc;
end

// memory side
// memory read number
always @(posedge clk_i) begin
    if (rst_i) mread_num <= 'd0;
    else if (is_working & is_read_mem)
        mread_num <= mread_num + 1;
    else mread_num <= mread_num;
end

// memory read latency
always @(posedge clk_i) begin
    if (rst_i) mread_ltc <= 'd0;
    else if (is_working & is_reading_mem)
        mread_ltc <= mread_ltc + 1;
    else mread_ltc <= mread_ltc;
end

// memory write number
always @(posedge clk_i) begin
    if (rst_i) mwrite_num <= 'd0;
    else if (is_working & is_write_mem)
        mwrite_num <= mwrite_num + 1;
    else mwrite_num <= mwrite_num;
end

// memory write latency
always @(posedge clk_i) begin
    if (rst_i) mwrite_ltc <= 'd0;
    else if (is_working & is_writing_mem)
        mwrite_ltc <= mwrite_ltc + 1;
    else mwrite_ltc <= mwrite_ltc;
end
//
// end of counters
//==========================================================










endmodule