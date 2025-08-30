`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/08 17:45:49
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
    parameter CNT_BITS = 64,
    parameter XLEN = 32
)(
    // system input
    input  clk_i,
    input  rst_i,
    
    input is_working_i,
    
    // input signals from i$
    input  [2 : 0] icache_S_i,
    
    // input signals from d$
    input  [3 : 0] dcache_S_i
);
//==========================================================
// local parameters
// state machine
localparam I_Init             = 0,
           I_Idle             = 1,
           I_Next             = 2,
           I_RdfromMem        = 3,
           I_RdfromMemFinish  = 4;
           
localparam D_Init             = 0,
           D_Idle             = 1,
           D_Analysis         = 2,
           D_WbtoMem          = 3,
           D_WbtoMemFinish    = 4,
           D_RdfromMem        = 5,
           D_RdfromMemFinish  = 6,
           D_WbtoMemAll       = 7,
           D_WbtoMemAllFinish = 8,
           D_RdAmo            = 9,
           D_RdAmoFinish      = 10;
//
// end of local parameters
//==========================================================
//==========================================================
// wires and registers
//
wire enter_iflush, enter_dflush_rd, enter_dflush_wb,
     in_iflush, in_dflush_rd, in_dflush_wb;

(* mark_debug = "true" *) reg  [CNT_BITS-1 : 0] 
    iflush_cnt, iflush_ltc, dflush_rd_cnt, dflush_rd_ltc,
    dflush_wb_cnt, dflush_wb_ltc;
//
// end of wires and registers
//==========================================================
//==========================================================
// wires assign
//
assign enter_iflush = (icache_S_i == I_RdfromMemFinish);
assign in_iflush    = (icache_S_i == I_RdfromMem |
                       icache_S_i == I_RdfromMemFinish);
assign enter_dflush_rd = (dcache_S_i == D_RdfromMemFinish);
assign enter_dflush_wb = (dcache_S_i == D_WbtoMemFinish);
assign in_dflush_rd    = (dcache_S_i == D_RdfromMem |              
                          dcache_S_i == D_RdfromMemFinish);
assign in_dflush_wb    = (dcache_S_i == D_WbtoMem |
                          dcache_S_i == D_WbtoMemFinish);

// registers control
always @(posedge clk_i)
begin
    if (rst_i)
    begin
        iflush_cnt    <= 0;
        iflush_ltc    <= 0;
        dflush_rd_cnt <= 0;
        dflush_rd_ltc <= 0;
        dflush_wb_cnt <= 0;
        dflush_wb_ltc <= 0;
    end
    else if (is_working_i)
    begin
        iflush_cnt    <= iflush_cnt    + enter_iflush;
        iflush_ltc    <= iflush_ltc    + in_iflush;
        dflush_rd_cnt <= dflush_rd_cnt + enter_dflush_rd;
        dflush_rd_ltc <= dflush_rd_ltc + in_dflush_rd;
        dflush_wb_cnt <= dflush_wb_cnt + enter_dflush_wb;
        dflush_wb_ltc <= dflush_wb_ltc + in_dflush_wb;
    end
    
    else
    begin
        iflush_cnt    <= iflush_cnt;
        iflush_ltc    <= iflush_ltc;
        dflush_rd_cnt <= dflush_rd_cnt;
        dflush_rd_ltc <= dflush_rd_ltc;
        dflush_wb_cnt <= dflush_wb_cnt;
        dflush_wb_ltc <= dflush_wb_ltc;
    end
    
end


endmodule
