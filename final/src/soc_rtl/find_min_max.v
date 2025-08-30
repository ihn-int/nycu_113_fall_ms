`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.12.2024 10:19:23
// Design Name: 
// Module Name: find_min_max
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


module find_min_max(
    // system input
    input   rst_i,
    input   clk_i,
    
    // module input
    input   en,
    input   wr,
    
    // write input
    input  [31: 0] waddr,
    input  [31: 0] din,
    output         rready,
    
    // read output
    input  [31: 0] raddr,
    output [31: 0] dout,
    output         wready
    );
   
localparam A    = 32'hC200_0000,
           min  = 32'hC200_0020,
           max  = 32'hC200_0024,
           trig = 32'hC200_0028;
localparam INT_MIN = 32'h8000_0000;
localparam INT_MAX = 32'h7FFF_FFFF;

reg signed [31: 0] A_rs[0:7];
reg [31: 0] min_r;
reg [31: 0] max_r;
reg [31: 0] trig_r;

wire re = en & ~wr;
wire we = en & wr;

// read ready signal


// A registers
wire re_a = (re & (raddr >= A && raddr < min));     // read A cell
wire we_a = (we & (waddr >= A && waddr < min));     // write A cell
reg  [31: 0] dout_a;

integer i;
always @(posedge clk_i) begin
    if (rst_i) begin
        for (i = 0; i < 8; i = i + 1)
            A_rs[i] <= 32'b0;
    end
    else begin
        if (re_a)
            dout_a <= A_rs[raddr[4:2]];
        else
            dout_a <= 32'b0; 
        if (we_a)
            A_rs[waddr[4:2]] <= din;
    end
end

// min regsiter
wire re_min = (re & (raddr == min));
// min is writeable for IP only
wire we_min;
reg [31: 0] din_min;
reg [31: 0] dout_min;
 
always @(posedge clk_i) begin
    if (rst_i) min_r <= 32'b0;
    else begin
        if (re_min) dout_min <= min_r;
        else dout_min <= min_r;
        if (we_min) min_r <= din_min;
    end
end

// max regsiter
wire re_max = (re & (raddr == max));
// max is writeable for IP only
wire we_max;
reg [31: 0] din_max;
reg [31: 0] dout_max;

always @(posedge clk_i) begin
    if (rst_i) max_r <= 32'b0;
    else dout_max <= max_r;
    if (we_max) max_r <= din_max;
end

// trig register
// state machine
localparam IDLE = 0, SET = 1, CALC = 2, TRAN = 3, SEND = 4;
reg [2 : 0] ns, ps;
reg [2 : 0] A_idx;

// ps logic
always @(posedge clk_i) begin
    if (rst_i) ps <= IDLE;
    else ps <= ns;
end

// ns logic
always @(*) begin
    if (rst_i) ns = IDLE;
    else case (ps)
        IDLE: ns = (trig_r > 0) ? SET : IDLE;
        SET : ns = CALC;
        CALC: ns = (A_idx == 3'o7) ? TRAN : CALC;
        TRAN: ns = SEND;
        SEND: ns = IDLE;
    endcase
end

// A_idx, min, max
always @(posedge clk_i) begin
    if (ps == SET) begin
        A_idx <= 32'b0;
        din_min <= INT_MAX;
        din_max <= INT_MIN;
    end
    else if (ps == CALC) begin
        A_idx <= A_idx + 1;
        
        // unsigned to signed
        case( {A_rs[A_idx][31], din_min[31]} )
            2'b00: // + +
                din_min <= (A_rs[A_idx] < din_min) ? A_rs[A_idx] : din_min;
            2'b01: // + -, choose min
                din_min <= din_min;
            2'b10: // - +, chosse A
                din_min <= A_rs[A_idx];
            2'b11: // - -, the greater one is bigger
                din_min <= (A_rs[A_idx] < din_min) ? A_rs[A_idx] : din_min;
        endcase
        case ( {A_rs[A_idx][31], din_max[31]} )
            2'b00: // + +
                din_max <= (A_rs[A_idx] > din_max) ? A_rs[A_idx] : din_max;
            2'b01: // + -, choose A
                din_max <= A_rs[A_idx];
            2'b10: // - +
                din_max <= din_max;
            2'b11: // - -, the greater one is smaller
                din_max <= (A_rs[A_idx] > din_max) ? A_rs[A_idx] : din_max;
        endcase
    end
    else begin
        A_idx <= A_idx;
        din_min <= din_min;
        din_max <= din_max;
    end
end

// trig
wire we_trig = (we & (waddr == trig));
wire re_trig = (re & (raddr == trig));
reg  [31: 0] dout_trig;

always @(posedge clk_i) begin
    if (rst_i) trig_r <= 32'b0;
    else if (re_trig) dout_trig <= trig_r;
    if (we_trig) trig_r <= din; // CPU write
    else if (ps == TRAN) trig_r <= 0;   // IP write
end

// we_min, we_max assign
assign we_min = (ps == TRAN);
assign we_max = (ps == TRAN);

// read ready assignment
reg rready_r;
assign rready = rready_r;
always @(posedge clk_i) begin
    if (re_a) rready_r <= 1;    // read A
    else if (re_min) rready_r <= 1;
    else if (re_max) rready_r <= 1;
    else if (re_trig) rready_r <= 1;
    else rready_r <= 0;
end 

// write ready assignment
reg wready_r;
assign wready = wready_r;
always @(posedge clk_i) begin
    if (we_a) wready_r <= 1;
    else if (we_trig) wready_r <= 1;
    else wready_r <= 0;
end

// dout assignment
// collect all re first
reg re_a_r, re_min_r, re_max_r, re_trig_r;
always @(posedge clk_i) begin
    re_a_r <= re_a;
    re_min_r <= re_min;
    re_max_r <= re_max;
    re_trig_r <= re_trig;
end

assign dout = 
    (re_a_r) ? dout_a :
    (re_min_r) ? dout_min :
    (re_max_r) ? dout_max :
    (re_trig_r) ? dout_trig : 32'b0;
    
endmodule
