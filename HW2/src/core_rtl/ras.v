`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/27 20:45:34
// Design Name: 
// Module Name: return_address_stack
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


module ras (
    // system input
    input           clk_i,
    input           rst_i,
    input           stall_i,
    
    // signals from PC
    input  [31: 0]  pc_i,
    
    // signals to program counter
    output          ras_hit_o,  //
    output [31: 0]  ras_addr_o, // also to execute stage
    
    // signals from decode stage
    input           dec_is_jal_i,
    input  [4 : 0]  dec_rd_addr_i,
    
    input           dec_is_jalr_i,
    input           dec_ras_hit_i,
    input           dec_is_ret_i,
    input  [31: 0]  dec_pc_i,
    
    // signals from execute stage
    input           exe_misprediction_i,
    
    // signals for execute stage
    // for pushing stack
    input  [31: 0]  exe_ras_restore_addr_i  // pc + 4
);

localparam STACK_LEN = 16;
localparam STACK_NBITS = $clog2(STACK_LEN);

localparam RAT_LEN = 64;
localparam RAT_NBITS = $clog2(RAT_LEN);

reg [31: 0] ras[STACK_LEN-1 : 0];
reg [STACK_NBITS-1 : 0] stack_pointer;
reg [31: 0] jalr_pc[RAT_LEN-1 : 0];

wire push_en = (~stall_i) & dec_is_jal_i & (dec_rd_addr_i == 5'b00001);
wire pop_en  = (~stall_i) & dec_is_ret_i; 


integer i, j;

// return address stack
always @(posedge clk_i) begin
    if (rst_i) begin
        for (i = 0; i < STACK_LEN; i = i + 1) begin
            ras[i] <= 32'b0;
        end
    end
    else if (push_en) begin
        ras[stack_pointer] <= exe_ras_restore_addr_i;
    end
end
   
// stack pointer
always @(posedge clk_i) begin
    if (rst_i) stack_pointer <= 'b0;
    else if (push_en) stack_pointer <= stack_pointer + 1'b1;
    else if (pop_en) stack_pointer <= stack_pointer - 1'b1;
    else stack_pointer <= stack_pointer;
end

wire [4 : 0] read_addr = pc_i[RAT_NBITS+1 : 2];
wire [4 : 0] write_addr = dec_pc_i[RAT_NBITS+1 : 2];
wire we = (~stall_i) & ~dec_ras_hit_i & (dec_is_ret_i);


// jalr_pc
always @(posedge clk_i) begin
    if (rst_i) for (j = 0; j < 32; j = j + 1)
        jalr_pc[j] <= 32'b0;
    else if (stall_i) for (j = 0; j < 32; j = j + 1)
        jalr_pc[j] <= jalr_pc[j];
    else if (we)
        jalr_pc[write_addr] <= dec_pc_i;
end


// output assignments
assign ras_addr_o = ras[stack_pointer - 1'b1];
assign ras_hit_o  = (jalr_pc[read_addr] == pc_i);

endmodule
