`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/29 12:38:21
// Design Name: 
// Module Name: profiler
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


module profiler #(
    parameter XLEN = 32,
    parameter CNT_LEN = 32
)(
    // system input
    input               clk_i,
    input               rst_i,
    input               stall_i,
    
    // signals from Decode
    input  [XLEN-1 : 0] pc_i,
    input               is_branch_i,
    input               is_jal_i,
    input               is_jalr_i,
    input  [2 : 0]      branch_type_i,
    input               branch_hit_i,
    input               branch_decision_i,
    input               ras_hit_i,
    
    // signals from Execute
    input               branch_taken_i,
    input               ras_misprediction_i
);

localparam [XLEN-1 : 0] STARTPOINT = 32'h00002e80, // crt0 start
                        ENDPOINT = 32'h00002eac;   // crt0 end
localparam [2 : 0]      F3_BEQ  = 3'b000,
                        F3_BNE  = 3'b001,
                        F3_BLT  = 3'b100,
                        F3_BGE  = 3'b101,
                        F3_BLTU = 3'b110,
                        F3_BGEU = 3'b111;

(* mark_debug = "true" *)
reg  [1 : 0] endflag;

(* mark_debug = "true" *)
reg  [31: 0] jalr_cnt, cache_miss_cnt,
    jal_cnt,  jal_tp, jal_fp, jal_tn, jal_fn,
    beq_cnt,  beq_tp, beq_fp, beq_tn, beq_fn,
    bne_cnt,  bne_tp, bne_fp, bne_tn, bne_fn,
    blt_cnt,  blt_tp, blt_fp, blt_tn, blt_fn,
    bge_cnt,  bge_tp, bge_fp, bge_tn, bge_fn,
    bltu_cnt, bltu_tp, bltu_fp, bltu_tn, bltu_fn,
    bgeu_cnt, bgeu_tp, bgeu_fp, bgeu_tn, bgeu_fn;
    
(* mark_debug = "true" *)
reg [31: 0] ras_hit_cnt, ras_miss_cnt;
    
wire is_beq, is_bne, is_blt, is_bge, is_bltu, is_bgeu;
wire is_jal, is_jalr;
wire is_working, is_flush;
wire [1 : 0] branch_pred;
wire is_tp, is_fp, is_tn, is_fn;

assign is_working = endflag[0] & ~stall_i;
assign is_beq  = is_branch_i && (branch_type_i == F3_BEQ);
assign is_bne  = is_branch_i && (branch_type_i == F3_BNE);
assign is_blt  = is_branch_i && (branch_type_i == F3_BLT);
assign is_bge  = is_branch_i && (branch_type_i == F3_BGE);
assign is_bltu = is_branch_i && (branch_type_i == F3_BLTU);
assign is_bgeu = is_branch_i && (branch_type_i == F3_BGEU);     
assign is_jal  = is_jal_i;
assign is_jalr = is_jalr_i;
assign branch_pred = { branch_decision_i, branch_taken_i };
assign is_tp = branch_hit_i & (branch_pred == 2'b11);
assign is_tn = branch_hit_i & (branch_pred == 2'b00);
assign is_fp = branch_hit_i & (branch_pred == 2'b10);
assign is_fn = branch_hit_i & (branch_pred == 2'b01);
assign flush_from_miss = (branch_taken_i & ~branch_hit_i);

// end flag, a small state machine
always@ (posedge clk_i) begin
    if (rst_i) endflag <= 0;
    else if (pc_i == STARTPOINT) endflag <= 1;
    else if (pc_i == ENDPOINT) endflag <= 2;
    else endflag <= endflag;
end

// all counter
always@ (posedge clk_i) begin
    if (rst_i) begin
        // counter
        jal_cnt   <= 32'h0;
        jalr_cnt  <= 32'h0;
        beq_cnt   <= 32'h0;
        bne_cnt   <= 32'h0;
        blt_cnt   <= 32'h0;
        bge_cnt   <= 32'h0;
        bltu_cnt  <= 32'h0;
        bgeu_cnt  <= 32'h0;
        cache_miss_cnt <= 32'h0;
        
        // tp
        beq_tp   <= 32'h0;
        bne_tp   <= 32'h0;
        blt_tp   <= 32'h0;
        bge_tp   <= 32'h0;
        bltu_tp  <= 32'h0;
        bgeu_tp  <= 32'h0;
        
        // tn
        beq_tn   <= 32'h0;
        bne_tn   <= 32'h0;
        blt_tn   <= 32'h0;
        bge_tn   <= 32'h0;
        bltu_tn  <= 32'h0;
        bgeu_tn  <= 32'h0;
        
        // fp
        beq_fp   <= 32'h0;
        bne_fp   <= 32'h0;
        blt_fp   <= 32'h0;
        bge_fp   <= 32'h0;
        bltu_fp  <= 32'h0;
        bgeu_fp  <= 32'h0;
        
        // fn
        beq_fn   <= 32'h0;
        bne_fn   <= 32'h0;
        blt_fn   <= 32'h0;
        bge_fn   <= 32'h0;
        bltu_fn  <= 32'h0;
        bgeu_fn  <= 32'h0;
    end
    else if (is_working) begin
        // counter
        jal_cnt   <= jal_cnt  + is_jal;
        jalr_cnt  <= jalr_cnt + is_jalr;
        beq_cnt   <= beq_cnt  + is_beq;
        bne_cnt   <= bne_cnt  + is_bne;
        blt_cnt   <= blt_cnt  + is_blt;
        bge_cnt   <= bge_cnt  + is_bge;
        bltu_cnt  <= bltu_cnt + is_bltu;
        bgeu_cnt  <= bgeu_cnt + is_bgeu;
        cache_miss_cnt <= cache_miss_cnt + flush_from_miss;
        // tp
        jal_tp    <= jal_tp  + (is_jal  & is_tp);
        beq_tp    <= beq_tp  + (is_beq  & is_tp);
        bne_tp    <= bne_tp  + (is_bne  & is_tp);
        blt_tp    <= blt_tp  + (is_blt  & is_tp);
        bge_tp    <= bge_tp  + (is_bge  & is_tp);
        bltu_tp   <= bltu_tp + (is_bltu & is_tp);
        bgeu_tp   <= bgeu_tp + (is_bgeu & is_tp);
        
        // tn
        jal_tn    <= jal_tn  + (is_jal  & is_tn);
        beq_tn    <= beq_tn  + (is_beq  & is_tn);
        bne_tn    <= bne_tn  + (is_bne  & is_tn);
        blt_tn    <= blt_tn  + (is_blt  & is_tn);
        bge_tn    <= bge_tn  + (is_bge  & is_tn);
        bltu_tn   <= bltu_tn + (is_bltu & is_tn);
        bgeu_tn   <= bgeu_tn + (is_bgeu & is_tn);
        
        // fp
        jal_fp    <= jal_fp  + (is_jal  & is_fp);
        beq_fp    <= beq_fp  + (is_beq  & is_fp);
        bne_fp    <= bne_fp  + (is_bne  & is_fp);
        blt_fp    <= blt_fp  + (is_blt  & is_fp);
        bge_fp    <= bge_fp  + (is_bge  & is_fp);
        bltu_fp   <= bltu_fp + (is_bltu & is_fp);
        bgeu_fp   <= bgeu_fp + (is_bgeu & is_fp);
        
        // fn
        jal_fn    <= jal_fn  + (is_jal  & is_fn);
        beq_fn    <= beq_fn  + (is_beq  & is_fn);
        bne_fn    <= bne_fn  + (is_bne  & is_fn);
        blt_fn    <= blt_fn  + (is_blt  & is_fn);
        bge_fn    <= bge_fn  + (is_bge  & is_fn);
        bltu_fn   <= bltu_fn + (is_bltu & is_fn);
        bgeu_fn   <= bgeu_fn + (is_bgeu & is_fn);
    end
    else begin
        // counter
        jal_cnt   <= jal_cnt ;
        jalr_cnt  <= jalr_cnt;
        beq_cnt   <= beq_cnt ;
        bne_cnt   <= bne_cnt ;
        blt_cnt   <= blt_cnt ;
        bge_cnt   <= bge_cnt ;
        bltu_cnt  <= bltu_cnt;
        bgeu_cnt  <= bgeu_cnt;
        cache_miss_cnt <= cache_miss_cnt;
        
        // tp
        jal_tp    <= jal_tp ;
        beq_tp    <= beq_tp ;
        bne_tp    <= bne_tp ;
        blt_tp    <= blt_tp ;
        bge_tp    <= bge_tp ;
        bltu_tp   <= bltu_tp;
        bgeu_tp   <= bgeu_tp;
        
        // tn
        jal_tn    <= jal_tn ;
        beq_tn    <= beq_tn ;
        bne_tn    <= bne_tn ;
        blt_tn    <= blt_tn ;
        bge_tn    <= bge_tn ;
        bltu_tn   <= bltu_tn;
        bgeu_tn   <= bgeu_tn;
        
        // fp
        jal_fp    <= jal_fp ;
        beq_fp    <= beq_fp ;
        bne_fp    <= bne_fp ;
        blt_fp    <= blt_fp ;
        bge_fp    <= bge_fp ;
        bltu_fp   <= bltu_fp;
        bgeu_fp   <= bgeu_fp;
        
        // fn
        jal_fn    <= jal_fn ;
        beq_fn    <= beq_fn ;
        bne_fn    <= bne_fn ;
        blt_fn    <= blt_fn ;
        bge_fn    <= bge_fn ;
        bltu_fn   <= bltu_fn;
        bgeu_fn   <= bgeu_fn;
    end
end

// ras
always @(posedge clk_i) begin
    if (rst_i) ras_hit_cnt <= 32'b0;
    else if (is_working) ras_hit_cnt <= ras_hit_cnt + ras_hit_i;
    else ras_hit_cnt <= ras_hit_cnt;
end

always @(posedge clk_i) begin
    if (rst_i) ras_miss_cnt <= 32'b0;
    else if (is_working) ras_miss_cnt <= ras_miss_cnt + ras_misprediction_i;
    else ras_miss_cnt <= ras_miss_cnt;
end

endmodule
