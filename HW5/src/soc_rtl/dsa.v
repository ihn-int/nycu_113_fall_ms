`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/11 20:11:27
// Design Name: 
// Module Name: dsa
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
`include "aquila_config.vh"

module dsa #(
    parameter XLEN = 32,
    parameter VEC_SIZE = 1024
)(
    // system input
    input clk_i,
    input rst_i,
    
    // signals from processor
    input                 S_dev_strobe_i,
    input  [XLEN-1 : 0]   S_dev_addr_i,
    input                 S_dev_rw_i,   // 0: read; 1: write
    input  [XLEN/8-1 : 0] S_dev_byte_enable_i,
    input  [XLEN-1 : 0]   S_dev_data_i,
    output                S_dev_data_ready_o,
    output [XLEN-1 : 0]   S_dev_data_o
);
//==========================================================
// local parameter
// device address for MMIO
localparam [XLEN-1 : 0]
    ARR_A  = 32'hC400_0000,
    ARR_B  = 32'hC401_0000,
    RESULT = 32'hC402_0000;
    
localparam VEC_BITS = $clog2(VEC_SIZE);
//==========================================================
// interface rename
//
wire dev_strobe, dev_rw, dev_ready;
wire [XLEN-1 : 0] dev_addr, dev_din;

// no be used here
assign dev_strobe = S_dev_strobe_i;
assign dev_rw     = S_dev_rw_i;
assign dev_addr   = S_dev_addr_i;
assign dev_din    = S_dev_data_i;

//==========================================================
// arrays
// common signals
wire [VEC_BITS-1 : 0] read_addr, write_addr;
wire we;

assign we = (dev_strobe) & (dev_rw);
assign write_addr = dev_addr[VEC_BITS+1 : 2];

// array A
wire we_A;
wire [XLEN-1 : 0] data_i_A, data_o_A;

distri_ram #(
    .ENTRY_NUM(VEC_SIZE),
    .XLEN(XLEN)
) vec_A (
    .clk_i(clk_i),
    .we_i(we_A),
    .read_addr_i(read_addr),
    .write_addr_i(write_addr),
    .data_i(data_i_A),
    .data_o(data_o_A)
);

assign we_A = (we) & (dev_addr[19:16] == 4'h0);
assign data_i_A = (we_A) ? dev_din : {XLEN{1'b0}};

// array B
wire we_B;
wire [XLEN-1 : 0] data_i_B, data_o_B;

distri_ram #(
    .ENTRY_NUM(VEC_SIZE),
    .XLEN(XLEN)
) vec_B (
    .clk_i(clk_i),
    .we_i(we_B),
    .read_addr_i(read_addr),
    .write_addr_i(write_addr),
    .data_i(data_i_B),
    .data_o(data_o_B)
);

assign we_B = (we) & (dev_addr[19:16] == 4'h1);
assign data_i_B = (we_B) ? dev_din : {XLEN{1'b0}};

//==========================================================
// for array B, we need a array to record the writing
//
reg  [VEC_SIZE-1 : 0] finish_B = 0;
reg  [VEC_BITS-1 : 0] bdx = 0;

always @(posedge clk_i)
begin
    if (rst_i)
    begin
        finish_B <= {VEC_SIZE{1'b0}};
        bdx <= 0;        
    end
    else if (we_B)
    begin
        finish_B[bdx] <= 1'b1;
        bdx <= bdx + 1;
    end
    else if (trans_D)  // clean up array if result is readed
    begin
        finish_B <= {VEC_SIZE{1'b0}};
        bdx <= 0;
    end
    else
    begin
        finish_B <= finish_B;
        bdx <= bdx;
    end
end

//==========================================================
// state machine for calculating FP
// FP signals first
wire [XLEN-1 : 0] S_AXIS_A_TDATA_O,
                  S_AXIS_B_TDATA_O,
                  S_AXIS_C_TDATA_O,
                  M_AXIS_RESULT_TDATA_I;
wire              S_AXIS_A_TVALID_O,
                  S_AXIS_B_TVALID_O,
                  S_AXIS_C_TVALID_O,
                  M_AXIS_RESULT_TVALID_I,
                  S_AXIS_A_TREADY_I,
                  S_AXIS_B_TREADY_I,
                  S_AXIS_C_TREADY_I,
                  M_AXIS_RESULT_TREADY_O;

floating_point_0 FP(
    // system clock
    .aclk(clk_i),
    
    // A port
    .s_axis_a_tdata(S_AXIS_A_TDATA_O),
    .s_axis_a_tvalid(S_AXIS_A_TVALID_O),
    .s_axis_a_tready(S_AXIS_A_TREADY_I),
    
    // B port
    .s_axis_b_tdata(S_AXIS_B_TDATA_O),
    .s_axis_b_tvalid(S_AXIS_B_TVALID_O),
    .s_axis_b_tready(S_AXIS_B_TREADY_I),
    
    // C port
    .s_axis_c_tdata(S_AXIS_C_TDATA_O),
    .s_axis_c_tvalid(S_AXIS_C_TVALID_O),
    .s_axis_c_tready(S_AXIS_C_TREADY_I),
    
    // Result port
    .m_axis_result_tdata(M_AXIS_RESULT_TDATA_I),
    .m_axis_result_tvalid(M_AXIS_RESULT_TVALID_I),
    .m_axis_result_tready(M_AXIS_RESULT_TREADY_O)
);

// state machine for FP
// Initialize make it correct in testbench
reg [3 : 0] S = 0, S_next = 0;

// finish_C records whether the data is ready.
reg [VEC_SIZE-1 : 0] finish_C = 0;
wire trans_A, trans_B, trans_C, trans_R;

localparam [1 : 0] S_IDLE = 0, S_INIT = 1,
                   S_CALC = 2, S_OUT  = 3;
// state register
always @(posedge clk_i)
begin
    if (rst_i) S <= S_IDLE;
    else S <= S_next;
end

// next state logic
always @(*)
begin
    if (rst_i) S_next = S_IDLE;
    else case (S)
        S_IDLE: S_next = (finish_B[fetch_addr]) ? S_INIT : S_IDLE;
        S_INIT: S_next = S_CALC;
        S_CALC: S_next = (M_AXIS_RESULT_TVALID_I) ? S_OUT : S_CALC;
        S_OUT : S_next = (trans_R) ? S_IDLE : S_OUT;
        default: S_next = S_IDLE;
    endcase
end

// registers used for FP
reg  valid_A, valid_B, valid_C;
wire [XLEN-1 : 0] data_A, data_B, data_C;

// signal rename
assign S_AXIS_A_TDATA_O = data_A;
assign S_AXIS_B_TDATA_O = data_B;
assign S_AXIS_C_TDATA_O = data_C;
assign S_AXIS_A_TVALID_O = valid_A;
assign S_AXIS_B_TVALID_O = valid_B;
assign S_AXIS_C_TVALID_O = valid_C;

// transfer signals from both dsa and FP
assign trans_A = (valid_A & S_AXIS_A_TREADY_I);
assign trans_B = (valid_B & S_AXIS_B_TREADY_I);
assign trans_C = (valid_C & S_AXIS_C_TREADY_I);
assign trans_R = M_AXIS_RESULT_TVALID_I & M_AXIS_RESULT_TREADY_O;
assign M_AXIS_RESULT_TREADY_O = (S == S_OUT);

// valid regsiter
// we make datas follow valid signals.
// Thus, these are more important 
always @(posedge clk_i)
begin
    if (rst_i)
    begin
        valid_A <= 0;
        valid_B <= 0;
        valid_C <= 0;
    end
    else case(S)
        S_IDLE:
        begin
            valid_A <= 0;
            valid_B <= 0;
            valid_C <= 0;
        end
        S_INIT:
        begin
            valid_A <= 1;
            valid_B <= 1;
            valid_C <= 1;
        end
        S_CALC:
        begin
            valid_A <= (trans_A) ? 0 : valid_A;
            valid_B <= (trans_B) ? 0 : valid_B;
            valid_C <= (trans_C) ? 0 : valid_C;
        end
        // no need for S_OUT
        default:
        begin
            valid_A <= 0;
            valid_B <= 0;
            valid_C <= 0;
        end
    endcase
end

assign data_A = (trans_A) ? data_o_A : 0;
assign data_B = (trans_B) ? data_o_B : 0;
assign data_C = (trans_C & (fetch_addr != 0)) ? data_o_C : 0;

// address counter (fetch address)
reg  [VEC_BITS-1 : 0] fetch_addr = 0;
always @(posedge clk_i)
begin
    if (rst_i) fetch_addr <= 0;
    else if (trans_D) fetch_addr <= 0;
        // clean up fetch address when read
    else if (S == S_OUT & S_next == S_IDLE)
        // fetch address must be hold until next data packet
        // S_OUT still use fetch address to write vector C
        fetch_addr <= fetch_addr + 1;
    else fetch_addr <= fetch_addr;
end

assign read_addr = fetch_addr;
assign read_addr_C = (trans_D) ?
    req_addr_C : fetch_addr - 1;
assign write_addr_C = fetch_addr;

// array C, C[i] = (A[i] * B[i]) + C[i-1], C[-1] == 0
wire we_C, re_C;
wire [XLEN-1 : 0] data_i_C, data_o_C, read_addr_C, write_addr_C;
// read_addr_C  = fetch_addr - 1
// write_addr_C = fetch_addr

// we must record the read request of array C
reg  re_C_r;
reg  [VEC_BITS-1 : 0] req_addr_C = 14'h3FFF;
wire trans_D;
assign trans_D = re_C_r & finish_C[req_addr_C];

// request address of array C
always @(posedge clk_i)
begin
    if (rst_i) req_addr_C <= {VEC_BITS{1'b1}};
    else if (re_C) req_addr_C <= dev_addr[VEC_BITS+1 : 2];
    else if (trans_D) req_addr_C <= 0;
    else req_addr_C <= req_addr_C;
end

// re_C_r
always @(posedge clk_i)
begin
    if (rst_i) re_C_r <= 0;
    else if (re_C) re_C_r <= 1;
    else if (trans_D) re_C_r <= 0;
    else re_C_r <= re_C_r;
end

assign data_i_C = (S == S_OUT) ? M_AXIS_RESULT_TDATA_I : 0;

distri_ram #(
    .ENTRY_NUM(VEC_SIZE),
    .XLEN(XLEN)
) vec_C (
    .clk_i(clk_i),
    .we_i(we_C),
    .read_addr_i(read_addr_C),
    .write_addr_i(write_addr_C),
    .data_i(data_i_C),
    .data_o(data_o_C)
);

assign re_C = (dev_strobe) & (~dev_rw) & (dev_addr[19:16] == 4'h2);
assign we_C = (S == S_OUT);


// finish_C registers
always @(posedge clk_i)
begin
    if (rst_i) finish_C <= 0;
    else if (trans_D) finish_C <= 0;
    else if (S == S_OUT) finish_C[write_addr_C] <= 1'b1;
    else finish_C <= finish_C;
end

// output signals
reg  dev_ready_o;
reg  [XLEN-1 : 0] dev_dout_o;
assign S_dev_data_ready_o = dev_ready_o;
assign S_dev_data_o       = dev_dout_o;

// ready signal
always @(posedge clk_i)
begin
    if (rst_i) dev_ready_o <= 0;
    else if (we) dev_ready_o <= 1;
    else if (trans_D) dev_ready_o <= 1;
    else dev_ready_o <= 0;
end

// data signal
always @(posedge clk_i)
begin
    if (rst_i) dev_dout_o <= 0;
    else if (trans_D) dev_dout_o <= data_o_C;
    else dev_dout_o <= 0;
end

// below is for profiler
/**/
localparam CNT_BITS = 32;
(* mark_debug = "true" *) reg  [CNT_BITS-1 :  0]
    tran_num, tran_ltc, calc_num, calc_ltc, wait_num, wait_ltc;
reg  in_tran, in_calc, in_wait, pre_tran, pre_calc, pre_wait;

always @(posedge clk_i)
begin
    if (rst_i) in_tran <= 0;
    else if (we_A) in_tran <= 1;
    else if (re_C) in_tran <= 0;
    else in_tran <= in_tran;
end

always @(posedge clk_i)
begin
    if (rst_i) in_wait <= 0;
    else if (re_C) in_wait <= 1;
    else if (trans_D) in_wait <= 0;
    else in_wait <= in_wait;
end

always @(posedge clk_i)
begin
    if (rst_i) in_calc <= 0;
    else if (trans_A) in_calc <= 1;
    else if (trans_D) in_calc <= 0;
    else in_calc <= in_calc;
end

always @(posedge clk_i)
begin
    pre_tran <= in_tran;
    pre_calc <= in_calc;
    pre_wait <= in_wait;
end
    
// transfer number, should be q + 1
always @(posedge clk_i)
begin
    if (rst_i) tran_num <= 0;
    else if (~pre_tran & in_tran) tran_num <= tran_num + 1;
    else tran_num <= tran_num;
end
// transfer latency, should be 20 * total number
always @(posedge clk_i)
begin
    if (rst_i) tran_ltc <= 0;
    else if (in_tran) tran_ltc <= tran_ltc + 1;
    else tran_ltc <= tran_ltc;
end

always @(posedge clk_i)
begin
    if (rst_i) calc_num <= 0;
    else if (~pre_calc & in_calc) calc_num <= calc_num + 1;
    else calc_num <= calc_num;
end

always @(posedge clk_i)
begin
    if (rst_i) calc_ltc <= 0;
    else if (in_calc) calc_ltc <= calc_ltc + 1;
    else calc_ltc <= calc_ltc;
end

always @(posedge clk_i)
begin
    if (rst_i) wait_num <= 0;
    else if (~pre_wait & in_wait) wait_num <= wait_num + 1;
    else wait_num <= wait_num;
end

always @(posedge clk_i)
begin
    if (rst_i) wait_ltc <= 0;
    else if (in_wait) wait_ltc <= wait_ltc + 1;
    else wait_ltc <= wait_ltc;
end


/**/







endmodule