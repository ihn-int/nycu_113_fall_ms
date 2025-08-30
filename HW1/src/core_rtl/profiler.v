`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/20 14:37:22
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
    parameter XLEN = 32
)(
    // system input
    input clk,
    input rst,

    // module input
    input  [XLEN-1 : 0] pc,
    input               stall  // stall_from_exe

    // module output
    /** /
    output              data_valid,
    output [XLEN-1 : 0] rank1_pc,    // rank 1 pc
    output [XLEN-1 : 0] rank1_comp,  // rank 1 computation cycles
    output [XLEN-1 : 0] rank1_stall, // rank 1 stall cycles
    output [XLEN-1 : 0] rank2_pc,    // rank 2 pc
    output [XLEN-1 : 0] rank2_comp,  // rank 2 computation cycles
    output [XLEN-1 : 0] rank2_stall, // rank 2 stall cycles
    output [XLEN-1 : 0] rank3_pc,    // rank 3 pc
    output [XLEN-1 : 0] rank3_comp,  // rank 3 computation cycles
    output [XLEN-1 : 0] rank3_stall, // rank 3 stall cycles
    output [XLEN-1 : 0] rank4_pc,    // rank 4 pc
    output [XLEN-1 : 0] rank4_comp,  // rank 4 computation cycles
    output [XLEN-1 : 0] rank4_stall, // rank 4 stall cycles
    output [XLEN-1 : 0] rank5_pc,    // rank 5 pc
    output [XLEN-1 : 0] rank5_comp,  // rank 5 computation cycles
    output [XLEN-1 : 0] rank5_stall  // rank 5 stall cycles
    /**/
    );
    
    
    
    localparam [XLEN-1 : 0]
    // core_main 
        iterate_start         = 32'h00001000,
        iterate_end           = 32'h00001084,
        main_start            = 32'h00001088,
        main_end              = 32'h000018e8,
    // core_portme
        portable_malloc_start = 32'h000018ec,
        portable_malloc_end   = 32'h000018ec,
        portable_free_start   = 32'h000018f0,
        portable_free_end     = 32'h000018f0,
        start_time_start      = 32'h000018f4,
        start_time_end        = 32'h00001910,
        stop_time_start       = 32'h00001914,
        stop_time_end         = 32'h00001930,
        get_time_start        = 32'h00001934,
        get_time_end          = 32'h00001948,
        time_in_secs_start    = 32'h0000194c,
        time_in_secs_end      = 32'h00001970,
        portable_init_start   = 32'h00001974,
        portable_init_end     = 32'h0000197c,
        portable_fini_start   = 32'h00001980,
        portable_fini_end     = 32'h00001984,
    // core_util
        get_seed_32_start     = 32'h00001988,
        get_seed_32_end       = 32'h000019e8,
        crcu8_start           = 32'h000019ec,
        crcu8_end             = 32'h00001a30,
        crcu16_start          = 32'h00001a34,
        crcu16_end            = 32'h00001a60,
        crcu32_start          = 32'h00001a64,
        crcu32_end            = 32'h00001a94,
        crc16_start           = 32'h00001a98,
        crc16_end             = 32'h00001aa0,
        check_data_types_start= 32'h00001aa4,
        check_data_types_end  = 32'h00001aa8,
    // core_list_join
        cmp_idx_start         = 32'h00001aac,
        cmp_idx_end           = 32'h00001b04,
        calc_func_start       = 32'h00001b08,
        calc_func_end         = 32'h00001c28,
        cmp_complex_start     = 32'h00001c2c,
        cmp_complex_end       = 32'h00001c74,
        copy_info_start       = 32'h00001c78,
        copy_info_end         = 32'h00001c88,
        core_list_insert_new_start = 32'h00001c8c,
        core_list_insert_new_end   = 32'h00001ce8,
        core_list_remove_start= 32'h00001cec,
        core_list_remove_end  = 32'h00001d10,
        core_list_undo_remove_start= 32'h00001d14,
        core_list_undo_remove_end  = 32'h00001d30,
        core_list_find_start       = 32'h00001d34,
        core_list_find_end         = 32'h00001d84,
        core_list_reverse_start    = 32'h00001d88,
        core_list_reverse_end      = 32'h00001da8,
        core_list_mergesort_start  = 32'h00001dac,
        core_list_mergesort_end    = 32'h00001ef8,
        core_bench_list_start      = 32'h00001efc,
        core_bench_list_end        = 32'h00002130,
        core_list_init_start       = 32'h00002134,
        core_list_init_end         = 32'h000022f4,
    // core_matrix
        core_init_matrix_start  = 32'h000022f8,
        core_init_matrix_end    = 32'h00002448,
        matrix_sum_start        = 32'h0000244c,
        matrix_sum_end          = 32'h000024dc,
        matrix_mul_const_start  = 32'h000024e0,
        matrix_mul_const_end    = 32'h00002534,
        matrix_add_const_start  = 32'h00002538,
        matrix_add_const_end    = 32'h00002580,
        matrix_mul_vect_start   = 32'h00002584,
        matrix_mul_vect_end     = 32'h000025d8,
        matrix_mul_matrix_start = 32'h000025dc,
        matrix_mul_matrix_end   = 32'h00002684,
        matrix_mul_matrix_bitextract_start = 32'h00002688,
        matrix_mul_matrix_bitextract_end   = 32'h00002744,
        matrix_test_start            = 32'h00002748,
        matrix_test_end              = 32'h000028a0,
        core_bench_matrix_start      = 32'h000028a4,
        core_bench_matrix_end        = 32'h000028dc,
    // core_state
        core_init_state_start        = 32'h000028e0,
        core_init_state_end          = 32'h00002a28,
        core_state_transition_start  = 32'h00002a2c,
        core_state_transition_end    = 32'h00002d14,
        core_bench_state_start       = 32'h00002d18,
        core_bench_state_end         = 32'h00002eb4,
    // elibc, crt0 
        crt0_start      = 32'h00002eb8,
        crt0_end        = 32'h00002ee4,
    // elibc, stdio
        getchar_start   = 32'h00002ee8,
        getchar_end     = 32'h00002efc,
        putchar_start   = 32'h00002f00,
        putchar_end     = 32'h00002f28,
        fputs_start     = 32'h00002f2c,
        fputs_end       = 32'h00002fa4,
        fgets_start     = 32'h00002fa8,
        fgets_end       = 32'h00003054,
        putd_start      = 32'h00003058,
        putd_end        = 32'h000031a8,
        putx_start      = 32'h000031ac,
        putx_end        = 32'h000032cc,
        putld_start     = 32'h000032d0,
        putld_end       = 32'h00003508,
        putf_start      = 32'h0000350c,
        putf_end        = 32'h00003814,
        printf_start    = 32'h00003818,
        printf_end      = 32'h00003a38,
    // elibc, stdlib
        exit_start      = 32'h00003a3c,
        exit_end        = 32'h00003a84,
        malloc_start    = 32'h00003a88,
        malloc_end      = 32'h00003bac,
        free_start      = 32'h00003bb0,
        free_end        = 32'h00003bd8,
        calloc_start    = 32'h00003bdc,
        calloc_end      = 32'h00003c14,
        atoi_start      = 32'h00003c18,
        atoi_end        = 32'h00003cac,
        abs_start       = 32'h00003cb0,
        abs_end         = 32'h00003cbc,
        srand_start     = 32'h00003cc0,
        srand_end       = 32'h00003cc8,
        rand_start      = 32'h00003ccc,
        rand_end        = 32'h00003cf8,
    // elibc, string
        memcpy_start    = 32'h00003cfc,
        memcpy_end      = 32'h00003d1c,
        memmove_start   = 32'h00003d20,
        memmove_end     = 32'h00003d78,
        memset_start    = 32'h00003d7c,
        memset_end      = 32'h00003d98,
        strlen_start    = 32'h00003d9c,
        strlen_end      = 32'h00003dc0,
        strcpy_start    = 32'h00003dc4,
        strcpy_end      = 32'h00003e44,
        strncpy_start   = 32'h00003e48,
        strncpy_end     = 32'h00003eac,
        strcat_start    = 32'h00003eb0,
        strcat_end      = 32'h00003ef0,
        strncat_start   = 32'h00003ef4,
        strncat_end     = 32'h00003f44,
        strcmp_start    = 32'h00003f48,
        strcmp_end      = 32'h00003fa8,
        strncmp_start   = 32'h00003fac,
        strncmp_end     = 32'h00003fec,
    // elibc, time
        clock_start     = 32'h00003ff0,
        clock_end       = 32'h00004030,
    // elibc, uart
        inbyte_start    = 32'h00004034,
        inbyte_end      = 32'h00004054,
        outbyte_start   = 32'h00004058,
        outbyte_end     = 32'h000040a0,
    // libgcc
        __divdi3_start  = 32'h000040a4,
        __divdi3_end    = 32'h00004518,
        __udivdi3_start = 32'h0000451c,
        __udivdi3_end   = 32'h00004948,
        __adddf3_start  = 32'h0000494c,
        __adddf3_end    = 32'h000050dc,
        __divdf3_start  = 32'h000050e0,
        __divdf3_end    = 32'h000057b8,
        __eqdf2_start   = 32'h000057bc,
        __eqdf2_end     = 32'h00005844,
        __gedf2_start   = 32'h00005848,
        __gedf2_end     = 32'h00005920,
        __ledf2_start   = 32'h00005924,
        __ledf2_end     = 32'h000059fc,
        __muldf3_start  = 32'h00005a00,
        __muldf3_end    = 32'h00005fec,
        __subdf3_start  = 32'h00005ff0,
        __subdf3_end    = 32'h00006794,
        __fixdfsi_start = 32'h00006798,
        __fixdfsi_end   = 32'h00006814,
        __fixunsdfsi_start  = 32'h00006818,
        __fixunsdfsi_end    = 32'h00006890,
        __floatsidf_start   = 32'h00006894,
        __floatsidf_end     = 32'h00006938,
        __floatunsidf_start = 32'h0000693c,
        __floatunsidf_end   = 32'h000069b8,
        __fixunsdfdi_start  = 32'h000069bc,
        __fixunsdfdi_end    = 32'h00006a60,
        __floatundidf_start = 32'h00006a64,
        __floatundidf_end   = 32'h00006c10,
        __lshrdi3_start     = 32'h00006c14,
        __lshrdi3_end       = 32'h00006c48,
        __ashldi3_start     = 32'h00006c4c,
        __ashldi3_end       = 32'h00006c80,
        __clzsi2_start      = 32'h00006c84,
        __clzsi2_end        = 32'h00006ccc;
    
    localparam [1 : 0] S_ADD = 0, S_CAL1 = 1, S_CAL2 = 2,
                       S_VALID = 3;
    
    (* mark_debug = "true" *) reg  [31: 0]
            // for 10 secs and 100 MHz, total cycle is roughly 1 G
            // 32 bit should be enough
		cnt[87:0];
	
	
	wire
		is_iterate,
		is_main,
		is_portable_malloc,
		is_portable_free,
		is_start_time,
		is_stop_time,
		is_get_time,
		is_time_in_secs,
		is_portable_init,
		is_portable_fini,
		is_get_seed_32,
		is_crcu8,
		is_crcu16,
		is_crcu32,
		is_crc16,
		is_check_data_types,
		is_cmp_idx,
		is_calc_func,
		is_cmp_complex,
		is_copy_info,
		is_core_list_insert_new,
		is_core_list_remove,
		is_core_list_undo_remove,
		is_core_list_find,
		is_core_list_reverse,
		is_core_list_mergesort,
		is_core_bench_list,
		is_core_list_init,
		is_core_init_matrix,
		is_matrix_sum,
		is_matrix_mul_const,
		is_matrix_add_const,
		is_matrix_mul_vect,
		is_matrix_mul_matrix,
		is_matrix_mul_matrix_bitextract,
		is_matrix_test,
		is_core_bench_matrix,
		is_core_state_transition,
		is_core_bench_state,
		is_crt0,
		is_getchar,
		is_putchar,
		is_fputs,
		is_fgets,
		is_putd,
		is_putx,
		is_putld,
		is_putf,
		is_printf,
		is_exit,
		is_malloc,
		is_free,
		is_calloc,
		is_atoi,
		is_abs,
		is_srand,
		is_rand,
		is_memcpy,
		is_memmove,
		is_memset,
		is_strlen,
		is_strcpy,
		is_strncpy,
		is_strcat,
		is_strncat,
		is_strcmp,
		is_strncmp,
		is_clock,
		is_inbyte,
		is_outbyte,
		is___divdi3,
		is___udivdi3,
		is___adddf3,
		is___divdf3,
		is___eqdf2,
		is___gedf2,
		is___ledf2,
		is___muldf3,
		is___subdf3,
		is___fixdfsi,
		is___fixunsdfsi,
		is___floatsidf,
		is___floatunsidf,
		is___fixunsdfdi,
		is___floatundidf,
		is___lshrdi3,
		is___ashldi3,
		is___clzsi2;
	
	
		
	reg  [1 : 0] ns, ps;
		
    assign is_iterate =
		(pc >= iterate_start & pc <= iterate_end);
	assign is_main =
		(pc >= main_start & pc <= main_end);
	assign is_portable_malloc =
		(pc >= portable_malloc_start & pc <= portable_malloc_end);
	assign is_portable_free =
		(pc >= portable_free_start & pc <= portable_free_end);
	assign is_start_time =
		(pc >= start_time_start & pc <= start_time_end);
	assign is_stop_time =
		(pc >= stop_time_start & pc <= stop_time_end);
	assign is_get_time =
		(pc >= get_time_start & pc <= get_time_end);
	assign is_time_in_secs =
		(pc >= time_in_secs_start & pc <= time_in_secs_end);
	assign is_portable_init =
		(pc >= portable_init_start & pc <= portable_init_end);
	assign is_portable_fini =
		(pc >= portable_fini_start & pc <= portable_fini_end);
	assign is_get_seed_32 =
		(pc >= get_seed_32_start & pc <= get_seed_32_end);
	assign is_crcu8 =
		(pc >= crcu8_start & pc <= crcu8_end);
	assign is_crcu16 =
		(pc >= crcu16_start & pc <= crcu16_end);
	assign is_crcu32 =
		(pc >= crcu32_start & pc <= crcu32_end);
	assign is_crc16 =
		(pc >= crc16_start & pc <= crc16_end);
	assign is_check_data_types =
		(pc >= check_data_types_start & pc <= check_data_types_end);
	assign is_cmp_idx =
		(pc >= cmp_idx_start & pc <= cmp_idx_end);
	assign is_calc_func =
		(pc >= calc_func_start & pc <= calc_func_end);
	assign is_cmp_complex =
		(pc >= cmp_complex_start & pc <= cmp_complex_end);
	assign is_copy_info =
		(pc >= copy_info_start & pc <= copy_info_end);
	assign is_core_list_insert_new =
		(pc >= core_list_insert_new_start & pc <= core_list_insert_new_end);
	assign is_core_list_remove =
		(pc >= core_list_remove_start & pc <= core_list_remove_end);
	assign is_core_list_undo_remove =
		(pc >= core_list_undo_remove_start & pc <= core_list_undo_remove_end);
	assign is_core_list_find =
		(pc >= core_list_find_start & pc <= core_list_find_end);
	assign is_core_list_reverse =
		(pc >= core_list_reverse_start & pc <= core_list_reverse_end);
	assign is_core_list_mergesort =
		(pc >= core_list_mergesort_start & pc <= core_list_mergesort_end);
	assign is_core_bench_list =
		(pc >= core_bench_list_start & pc <= core_bench_list_end);
	assign is_core_list_init =
		(pc >= core_list_init_start & pc <= core_list_init_end);
	assign is_core_init_matrix =
		(pc >= core_init_matrix_start & pc <= core_init_matrix_end);
	assign is_matrix_sum =
		(pc >= matrix_sum_start & pc <= matrix_sum_end);
	assign is_matrix_mul_const =
		(pc >= matrix_mul_const_start & pc <= matrix_mul_const_end);
	assign is_matrix_add_const =
		(pc >= matrix_add_const_start & pc <= matrix_add_const_end);
	assign is_matrix_mul_vect =
		(pc >= matrix_mul_vect_start & pc <= matrix_mul_vect_end);
	assign is_matrix_mul_matrix =
		(pc >= matrix_mul_matrix_start & pc <= matrix_mul_matrix_end);
	assign is_matrix_mul_matrix_bitextract =
		(pc >= matrix_mul_matrix_bitextract_start & pc <= matrix_mul_matrix_bitextract_end);
	assign is_matrix_test =
		(pc >= matrix_test_start & pc <= matrix_test_end);
	assign is_core_bench_matrix =
		(pc >= core_bench_matrix_start & pc <= core_bench_matrix_end);
	assign is_core_state_transition =
		(pc >= core_state_transition_start & pc <= core_state_transition_end);
	assign is_core_bench_state =
		(pc >= core_bench_state_start & pc <= core_bench_state_end);
	assign is_crt0 =
		(pc >= crt0_start & pc <= crt0_end);
	assign is_getchar =
		(pc >= getchar_start & pc <= getchar_end);
	assign is_putchar =
		(pc >= putchar_start & pc <= putchar_end);
	assign is_fputs =
		(pc >= fputs_start & pc <= fputs_end);
	assign is_fgets =
		(pc >= fgets_start & pc <= fgets_end);
	assign is_putd =
		(pc >= putd_start & pc <= putd_end);
	assign is_putx =
		(pc >= putx_start & pc <= putx_end);
	assign is_putld =
		(pc >= putld_start & pc <= putld_end);
	assign is_putf =
		(pc >= putf_start & pc <= putf_end);
	assign is_printf =
		(pc >= printf_start & pc <= printf_end);
	assign is_exit =
		(pc >= exit_start & pc <= exit_end);
	assign is_malloc =
		(pc >= malloc_start & pc <= malloc_end);
	assign is_free =
		(pc >= free_start & pc <= free_end);
	assign is_calloc =
		(pc >= calloc_start & pc <= calloc_end);
	assign is_atoi =
		(pc >= atoi_start & pc <= atoi_end);
	assign is_abs =
		(pc >= abs_start & pc <= abs_end);
	assign is_srand =
		(pc >= srand_start & pc <= srand_end);
	assign is_rand =
		(pc >= rand_start & pc <= rand_end);
	assign is_memcpy =
		(pc >= memcpy_start & pc <= memcpy_end);
	assign is_memmove =
		(pc >= memmove_start & pc <= memmove_end);
	assign is_memset =
		(pc >= memset_start & pc <= memset_end);
	assign is_strlen =
		(pc >= strlen_start & pc <= strlen_end);
	assign is_strcpy =
		(pc >= strcpy_start & pc <= strcpy_end);
	assign is_strncpy =
		(pc >= strncpy_start & pc <= strncpy_end);
	assign is_strcat =
		(pc >= strcat_start & pc <= strcat_end);
	assign is_strncat =
		(pc >= strncat_start & pc <= strncat_end);
	assign is_strcmp =
		(pc >= strcmp_start & pc <= strcmp_end);
	assign is_strncmp =
		(pc >= strncmp_start & pc <= strncmp_end);
	assign is_clock =
		(pc >= clock_start & pc <= clock_end);
	assign is_inbyte =
		(pc >= inbyte_start & pc <= inbyte_end);
	assign is_outbyte =
		(pc >= outbyte_start & pc <= outbyte_end);
	assign is___divdi3 =
		(pc >= __divdi3_start & pc <= __divdi3_end);
	assign is___udivdi3 =
		(pc >= __udivdi3_start & pc <= __udivdi3_end);
	assign is___adddf3 =
		(pc >= __adddf3_start & pc <= __adddf3_end);
	assign is___divdf3 =
		(pc >= __divdf3_start & pc <= __divdf3_end);
	assign is___eqdf2 =
		(pc >= __eqdf2_start & pc <= __eqdf2_end);
	assign is___gedf2 =
		(pc >= __gedf2_start & pc <= __gedf2_end);
	assign is___ledf2 =
		(pc >= __ledf2_start & pc <= __ledf2_end);
	assign is___muldf3 =
		(pc >= __muldf3_start & pc <= __muldf3_end);
	assign is___subdf3 =
		(pc >= __subdf3_start & pc <= __subdf3_end);
	assign is___fixdfsi =
		(pc >= __fixdfsi_start & pc <= __fixdfsi_end);
	assign is___fixunsdfsi =
		(pc >= __fixunsdfsi_start & pc <= __fixunsdfsi_end);
	assign is___floatsidf =
		(pc >= __floatsidf_start & pc <= __floatsidf_end);
	assign is___floatunsidf =
		(pc >= __floatunsidf_start & pc <= __floatunsidf_end);
	assign is___fixunsdfdi =
		(pc >= __fixunsdfdi_start & pc <= __fixunsdfdi_end);
	assign is___floatundidf =
		(pc >= __floatundidf_start & pc <= __floatundidf_end);
	assign is___lshrdi3 =
		(pc >= __lshrdi3_start & pc <= __lshrdi3_end);
	assign is___ashldi3 =
		(pc >= __ashldi3_start & pc <= __ashldi3_end);
	assign is___clzsi2 =
		(pc >= __clzsi2_start & pc <= __clzsi2_end);
		
    
    // FSM
    
    
    // ps
    always@(posedge clk) begin
        if (rst) ps <= S_ADD;
        else ps <= ns;
    end
    
    // ns    
    always@(*) begin
        if(rst) ns = S_ADD;
        else
        case(ps)
        S_ADD  : ns = (pc == 32'h0000_2ee4) ? S_VALID : S_ADD;
        S_VALID: ns = S_VALID;
        default: ns = S_ADD;
        endcase 
    end
    
	always@(posedge clk)
		if(rst) cnt[ 0]  <= 26'h0;
		else if(is_iterate & stall & ps == S_ADD) cnt[ 0] <= cnt[ 0]  + 1;
		else cnt[ 0] <= cnt[ 0];
	always@(posedge clk)
		if(rst) cnt[ 1]  <= 26'h0;
		else if(is_main & stall & ps == S_ADD) cnt[ 1] <= cnt[ 1]  + 1;
		else cnt[ 1] <= cnt[ 1];
	always@(posedge clk)
		if(rst) cnt[ 2]  <= 26'h0;
		else if(is_portable_malloc & stall & ps == S_ADD) cnt[ 2] <= cnt[ 2]  + 1;
		else cnt[ 2] <= cnt[ 2];
	always@(posedge clk)
		if(rst) cnt[ 3]  <= 26'h0;
		else if(is_portable_free & stall & ps == S_ADD) cnt[ 3] <= cnt[ 3]  + 1;
		else cnt[ 3] <= cnt[ 3];
	always@(posedge clk)
		if(rst) cnt[ 4]  <= 26'h0;
		else if(is_start_time & stall & ps == S_ADD) cnt[ 4] <= cnt[ 4]  + 1;
		else cnt[ 4] <= cnt[ 4];
	always@(posedge clk)
		if(rst) cnt[ 5]  <= 26'h0;
		else if(is_stop_time & stall & ps == S_ADD) cnt[ 5] <= cnt[ 5]  + 1;
		else cnt[ 5] <= cnt[ 5];
	always@(posedge clk)
		if(rst) cnt[ 6]  <= 26'h0;
		else if(is_get_time & stall & ps == S_ADD) cnt[ 6] <= cnt[ 6]  + 1;
		else cnt[ 6] <= cnt[ 6];
	always@(posedge clk)
		if(rst) cnt[ 7]  <= 26'h0;
		else if(is_time_in_secs & stall & ps == S_ADD) cnt[ 7] <= cnt[ 7]  + 1;
		else cnt[ 7] <= cnt[ 7];
	always@(posedge clk)
		if(rst) cnt[ 8]  <= 26'h0;
		else if(is_portable_init & stall & ps == S_ADD) cnt[ 8] <= cnt[ 8]  + 1;
		else cnt[ 8] <= cnt[ 8];
	always@(posedge clk)
		if(rst) cnt[ 9]  <= 26'h0;
		else if(is_portable_fini & stall & ps == S_ADD) cnt[ 9] <= cnt[ 9]  + 1;
		else cnt[ 9] <= cnt[ 9];
	always@(posedge clk)
		if(rst) cnt[10]  <= 26'h0;
		else if(is_get_seed_32 & stall & ps == S_ADD) cnt[10] <= cnt[10]  + 1;
		else cnt[10] <= cnt[10];
	always@(posedge clk)
		if(rst) cnt[11]  <= 26'h0;
		else if(is_crcu8 & stall & ps == S_ADD) cnt[11] <= cnt[11]  + 1;
		else cnt[11] <= cnt[11];
	always@(posedge clk)
		if(rst) cnt[12]  <= 26'h0;
		else if(is_crcu16 & stall & ps == S_ADD) cnt[12] <= cnt[12]  + 1;
		else cnt[12] <= cnt[12];
	always@(posedge clk)
		if(rst) cnt[13]  <= 26'h0;
		else if(is_crcu32 & stall & ps == S_ADD) cnt[13] <= cnt[13]  + 1;
		else cnt[13] <= cnt[13];
	always@(posedge clk)
		if(rst) cnt[14]  <= 26'h0;
		else if(is_crc16 & stall & ps == S_ADD) cnt[14] <= cnt[14]  + 1;
		else cnt[14] <= cnt[14];
	always@(posedge clk)
		if(rst) cnt[15]  <= 26'h0;
		else if(is_check_data_types & stall & ps == S_ADD) cnt[15] <= cnt[15]  + 1;
		else cnt[15] <= cnt[15];
	always@(posedge clk)
		if(rst) cnt[16]  <= 26'h0;
		else if(is_cmp_idx & stall & ps == S_ADD) cnt[16] <= cnt[16]  + 1;
		else cnt[16] <= cnt[16];
	always@(posedge clk)
		if(rst) cnt[17]  <= 26'h0;
		else if(is_calc_func & stall & ps == S_ADD) cnt[17] <= cnt[17]  + 1;
		else cnt[17] <= cnt[17];
	always@(posedge clk)
		if(rst) cnt[18]  <= 26'h0;
		else if(is_cmp_complex & stall & ps == S_ADD) cnt[18] <= cnt[18]  + 1;
		else cnt[18] <= cnt[18];
	always@(posedge clk)
		if(rst) cnt[19]  <= 26'h0;
		else if(is_copy_info & stall & ps == S_ADD) cnt[19] <= cnt[19]  + 1;
		else cnt[19] <= cnt[19];
	always@(posedge clk)
		if(rst) cnt[20]  <= 26'h0;
		else if(is_core_list_insert_new & stall & ps == S_ADD) cnt[20] <= cnt[20]  + 1;
		else cnt[20] <= cnt[20];
	always@(posedge clk)
		if(rst) cnt[21]  <= 26'h0;
		else if(is_core_list_remove & stall & ps == S_ADD) cnt[21] <= cnt[21]  + 1;
		else cnt[21] <= cnt[21];
	always@(posedge clk)
		if(rst) cnt[22]  <= 26'h0;
		else if(is_core_list_undo_remove & stall & ps == S_ADD) cnt[22] <= cnt[22]  + 1;
		else cnt[22] <= cnt[22];
	always@(posedge clk)
		if(rst) cnt[23]  <= 26'h0;
		else if(is_core_list_find & stall & ps == S_ADD) cnt[23] <= cnt[23]  + 1;
		else cnt[23] <= cnt[23];
	always@(posedge clk)
		if(rst) cnt[24]  <= 26'h0;
		else if(is_core_list_reverse & stall & ps == S_ADD) cnt[24] <= cnt[24]  + 1;
		else cnt[24] <= cnt[24];
	always@(posedge clk)
		if(rst) cnt[25]  <= 26'h0;
		else if(is_core_list_mergesort & stall & ps == S_ADD) cnt[25] <= cnt[25]  + 1;
		else cnt[25] <= cnt[25];
	always@(posedge clk)
		if(rst) cnt[26]  <= 26'h0;
		else if(is_core_bench_list & stall & ps == S_ADD) cnt[26] <= cnt[26]  + 1;
		else cnt[26] <= cnt[26];
	always@(posedge clk)
		if(rst) cnt[27]  <= 26'h0;
		else if(is_core_list_init & stall & ps == S_ADD) cnt[27] <= cnt[27]  + 1;
		else cnt[27] <= cnt[27];
	always@(posedge clk)
		if(rst) cnt[28]  <= 26'h0;
		else if(is_core_init_matrix & stall & ps == S_ADD) cnt[28] <= cnt[28]  + 1;
		else cnt[28] <= cnt[28];
	always@(posedge clk)
		if(rst) cnt[29]  <= 26'h0;
		else if(is_matrix_sum & stall & ps == S_ADD) cnt[29] <= cnt[29]  + 1;
		else cnt[29] <= cnt[29];
	always@(posedge clk)
		if(rst) cnt[30]  <= 26'h0;
		else if(is_matrix_mul_const & stall & ps == S_ADD) cnt[30] <= cnt[30]  + 1;
		else cnt[30] <= cnt[30];
	always@(posedge clk)
		if(rst) cnt[31]  <= 26'h0;
		else if(is_matrix_add_const & stall & ps == S_ADD) cnt[31] <= cnt[31]  + 1;
		else cnt[31] <= cnt[31];
	always@(posedge clk)
		if(rst) cnt[32]  <= 26'h0;
		else if(is_matrix_mul_vect & stall & ps == S_ADD) cnt[32] <= cnt[32]  + 1;
		else cnt[32] <= cnt[32];
	always@(posedge clk)
		if(rst) cnt[33]  <= 26'h0;
		else if(is_matrix_mul_matrix & stall & ps == S_ADD) cnt[33] <= cnt[33]  + 1;
		else cnt[33] <= cnt[33];
	always@(posedge clk)
		if(rst) cnt[34]  <= 26'h0;
		else if(is_matrix_mul_matrix_bitextract & stall & ps == S_ADD) cnt[34] <= cnt[34]  + 1;
		else cnt[34] <= cnt[34];
	always@(posedge clk)
		if(rst) cnt[35]  <= 26'h0;
		else if(is_matrix_test & stall & ps == S_ADD) cnt[35] <= cnt[35]  + 1;
		else cnt[35] <= cnt[35];
	always@(posedge clk)
		if(rst) cnt[36]  <= 26'h0;
		else if(is_core_bench_matrix & stall & ps == S_ADD) cnt[36] <= cnt[36]  + 1;
		else cnt[36] <= cnt[36];
	always@(posedge clk)
		if(rst) cnt[37]  <= 26'h0;
		else if(is_core_state_transition & stall & ps == S_ADD) cnt[37] <= cnt[37]  + 1;
		else cnt[37] <= cnt[37];
	always@(posedge clk)
		if(rst) cnt[38]  <= 26'h0;
		else if(is_core_bench_state & stall & ps == S_ADD) cnt[38] <= cnt[38]  + 1;
		else cnt[38] <= cnt[38];
	always@(posedge clk)
		if(rst) cnt[39]  <= 26'h0;
		else if(is_crt0 & stall & ps == S_ADD) cnt[39] <= cnt[39]  + 1;
		else cnt[39] <= cnt[39];
	always@(posedge clk)
		if(rst) cnt[40]  <= 26'h0;
		else if(is_getchar & stall & ps == S_ADD) cnt[40] <= cnt[40]  + 1;
		else cnt[40] <= cnt[40];
	always@(posedge clk)
		if(rst) cnt[41]  <= 26'h0;
		else if(is_putchar & stall & ps == S_ADD) cnt[41] <= cnt[41]  + 1;
		else cnt[41] <= cnt[41];
	always@(posedge clk)
		if(rst) cnt[42]  <= 26'h0;
		else if(is_fputs & stall & ps == S_ADD) cnt[42] <= cnt[42]  + 1;
		else cnt[42] <= cnt[42];
	always@(posedge clk)
		if(rst) cnt[43]  <= 26'h0;
		else if(is_fgets & stall & ps == S_ADD) cnt[43] <= cnt[43]  + 1;
		else cnt[43] <= cnt[43];
	always@(posedge clk)
		if(rst) cnt[44]  <= 26'h0;
		else if(is_putd & stall & ps == S_ADD) cnt[44] <= cnt[44]  + 1;
		else cnt[44] <= cnt[44];
	always@(posedge clk)
		if(rst) cnt[45]  <= 26'h0;
		else if(is_putx & stall & ps == S_ADD) cnt[45] <= cnt[45]  + 1;
		else cnt[45] <= cnt[45];
	always@(posedge clk)
		if(rst) cnt[46]  <= 26'h0;
		else if(is_putld & stall & ps == S_ADD) cnt[46] <= cnt[46]  + 1;
		else cnt[46] <= cnt[46];
	always@(posedge clk)
		if(rst) cnt[47]  <= 26'h0;
		else if(is_putf & stall & ps == S_ADD) cnt[47] <= cnt[47]  + 1;
		else cnt[47] <= cnt[47];
	always@(posedge clk)
		if(rst) cnt[48]  <= 26'h0;
		else if(is_printf & stall & ps == S_ADD) cnt[48] <= cnt[48]  + 1;
		else cnt[48] <= cnt[48];
	always@(posedge clk)
		if(rst) cnt[49]  <= 26'h0;
		else if(is_exit & stall & ps == S_ADD) cnt[49] <= cnt[49]  + 1;
		else cnt[49] <= cnt[49];
	always@(posedge clk)
		if(rst) cnt[50]  <= 26'h0;
		else if(is_malloc & stall & ps == S_ADD) cnt[50] <= cnt[50]  + 1;
		else cnt[50] <= cnt[50];
	always@(posedge clk)
		if(rst) cnt[51]  <= 26'h0;
		else if(is_free & stall & ps == S_ADD) cnt[51] <= cnt[51]  + 1;
		else cnt[51] <= cnt[51];
	always@(posedge clk)
		if(rst) cnt[52]  <= 26'h0;
		else if(is_calloc & stall & ps == S_ADD) cnt[52] <= cnt[52]  + 1;
		else cnt[52] <= cnt[52];
	always@(posedge clk)
		if(rst) cnt[53]  <= 26'h0;
		else if(is_atoi & stall & ps == S_ADD) cnt[53] <= cnt[53]  + 1;
		else cnt[53] <= cnt[53];
	always@(posedge clk)
		if(rst) cnt[54]  <= 26'h0;
		else if(is_abs & stall & ps == S_ADD) cnt[54] <= cnt[54]  + 1;
		else cnt[54] <= cnt[54];
	always@(posedge clk)
		if(rst) cnt[55]  <= 26'h0;
		else if(is_srand & stall & ps == S_ADD) cnt[55] <= cnt[55]  + 1;
		else cnt[55] <= cnt[55];
	always@(posedge clk)
		if(rst) cnt[56]  <= 26'h0;
		else if(is_rand & stall & ps == S_ADD) cnt[56] <= cnt[56]  + 1;
		else cnt[56] <= cnt[56];
	always@(posedge clk)
		if(rst) cnt[57]  <= 26'h0;
		else if(is_memcpy & stall & ps == S_ADD) cnt[57] <= cnt[57]  + 1;
		else cnt[57] <= cnt[57];
	always@(posedge clk)
		if(rst) cnt[58]  <= 26'h0;
		else if(is_memmove & stall & ps == S_ADD) cnt[58] <= cnt[58]  + 1;
		else cnt[58] <= cnt[58];
	always@(posedge clk)
		if(rst) cnt[59]  <= 26'h0;
		else if(is_memset & stall & ps == S_ADD) cnt[59] <= cnt[59]  + 1;
		else cnt[59] <= cnt[59];
	always@(posedge clk)
		if(rst) cnt[60]  <= 26'h0;
		else if(is_strlen & stall & ps == S_ADD) cnt[60] <= cnt[60]  + 1;
		else cnt[60] <= cnt[60];
	always@(posedge clk)
		if(rst) cnt[61]  <= 26'h0;
		else if(is_strcpy & stall & ps == S_ADD) cnt[61] <= cnt[61]  + 1;
		else cnt[61] <= cnt[61];
	always@(posedge clk)
		if(rst) cnt[62]  <= 26'h0;
		else if(is_strncpy & stall & ps == S_ADD) cnt[62] <= cnt[62]  + 1;
		else cnt[62] <= cnt[62];
	always@(posedge clk)
		if(rst) cnt[63]  <= 26'h0;
		else if(is_strcat & stall & ps == S_ADD) cnt[63] <= cnt[63]  + 1;
		else cnt[63] <= cnt[63];
	always@(posedge clk)
		if(rst) cnt[64]  <= 26'h0;
		else if(is_strncat & stall & ps == S_ADD) cnt[64] <= cnt[64]  + 1;
		else cnt[64] <= cnt[64];
	always@(posedge clk)
		if(rst) cnt[65]  <= 26'h0;
		else if(is_strcmp & stall & ps == S_ADD) cnt[65] <= cnt[65]  + 1;
		else cnt[65] <= cnt[65];
	always@(posedge clk)
		if(rst) cnt[66]  <= 26'h0;
		else if(is_strncmp & stall & ps == S_ADD) cnt[66] <= cnt[66]  + 1;
		else cnt[66] <= cnt[66];
	always@(posedge clk)
		if(rst) cnt[67]  <= 26'h0;
		else if(is_clock & stall & ps == S_ADD) cnt[67] <= cnt[67]  + 1;
		else cnt[67] <= cnt[67];
	always@(posedge clk)
		if(rst) cnt[68]  <= 26'h0;
		else if(is_inbyte & stall & ps == S_ADD) cnt[68] <= cnt[68]  + 1;
		else cnt[68] <= cnt[68];
	always@(posedge clk)
		if(rst) cnt[69]  <= 26'h0;
		else if(is_outbyte & stall & ps == S_ADD) cnt[69] <= cnt[69]  + 1;
		else cnt[69] <= cnt[69];
	always@(posedge clk)
		if(rst) cnt[70]  <= 26'h0;
		else if(is___divdi3 & stall & ps == S_ADD) cnt[70] <= cnt[70]  + 1;
		else cnt[70] <= cnt[70];
	always@(posedge clk)
		if(rst) cnt[71]  <= 26'h0;
		else if(is___udivdi3 & stall & ps == S_ADD) cnt[71] <= cnt[71]  + 1;
		else cnt[71] <= cnt[71];
	always@(posedge clk)
		if(rst) cnt[72]  <= 26'h0;
		else if(is___adddf3 & stall & ps == S_ADD) cnt[72] <= cnt[72]  + 1;
		else cnt[72] <= cnt[72];
	always@(posedge clk)
		if(rst) cnt[73]  <= 26'h0;
		else if(is___divdf3 & stall & ps == S_ADD) cnt[73] <= cnt[73]  + 1;
		else cnt[73] <= cnt[73];
	always@(posedge clk)
		if(rst) cnt[74]  <= 26'h0;
		else if(is___eqdf2 & stall & ps == S_ADD) cnt[74] <= cnt[74]  + 1;
		else cnt[74] <= cnt[74];
	always@(posedge clk)
		if(rst) cnt[75]  <= 26'h0;
		else if(is___gedf2 & stall & ps == S_ADD) cnt[75] <= cnt[75]  + 1;
		else cnt[75] <= cnt[75];
	always@(posedge clk)
		if(rst) cnt[76]  <= 26'h0;
		else if(is___ledf2 & stall & ps == S_ADD) cnt[76] <= cnt[76]  + 1;
		else cnt[76] <= cnt[76];
	always@(posedge clk)
		if(rst) cnt[77]  <= 26'h0;
		else if(is___muldf3 & stall & ps == S_ADD) cnt[77] <= cnt[77]  + 1;
		else cnt[77] <= cnt[77];
	always@(posedge clk)
		if(rst) cnt[78]  <= 26'h0;
		else if(is___subdf3 & stall & ps == S_ADD) cnt[78] <= cnt[78]  + 1;
		else cnt[78] <= cnt[78];
	always@(posedge clk)
		if(rst) cnt[79]  <= 26'h0;
		else if(is___fixdfsi & stall & ps == S_ADD) cnt[79] <= cnt[79]  + 1;
		else cnt[79] <= cnt[79];
	always@(posedge clk)
		if(rst) cnt[80]  <= 26'h0;
		else if(is___fixunsdfsi & stall & ps == S_ADD) cnt[80] <= cnt[80]  + 1;
		else cnt[80] <= cnt[80];
	always@(posedge clk)
		if(rst) cnt[81]  <= 26'h0;
		else if(is___floatsidf & stall & ps == S_ADD) cnt[81] <= cnt[81]  + 1;
		else cnt[81] <= cnt[81];
	always@(posedge clk)
		if(rst) cnt[82]  <= 26'h0;
		else if(is___floatunsidf & stall & ps == S_ADD) cnt[82] <= cnt[82]  + 1;
		else cnt[82] <= cnt[82];
	always@(posedge clk)
		if(rst) cnt[83]  <= 26'h0;
		else if(is___fixunsdfdi & stall & ps == S_ADD) cnt[83] <= cnt[83]  + 1;
		else cnt[83] <= cnt[83];
	always@(posedge clk)
		if(rst) cnt[84]  <= 26'h0;
		else if(is___floatundidf & stall & ps == S_ADD) cnt[84] <= cnt[84]  + 1;
		else cnt[84] <= cnt[84];
	always@(posedge clk)
		if(rst) cnt[85]  <= 26'h0;
		else if(is___lshrdi3 & stall & ps == S_ADD) cnt[85] <= cnt[85]  + 1;
		else cnt[85] <= cnt[85];
	always@(posedge clk)
		if(rst) cnt[86]  <= 26'h0;
		else if(is___ashldi3 & stall & ps == S_ADD) cnt[86] <= cnt[86]  + 1;
		else cnt[86] <= cnt[86];
	always@(posedge clk)
		if(rst) cnt[87]  <= 26'h0;
		else if(is___clzsi2 & stall & ps == S_ADD) cnt[87] <= cnt[87]  + 1;
		else cnt[87] <= cnt[87];
	
    // output port
    /** /
    assign datavalid = ps == S_VALID;
    assign rank1_pc    = pc_record[0];
    assign rank1_comp  = cycle_cnt[0];
    assign rank1_stall = stall_cnt[0];
    assign rank2_pc    = pc_record[1];
    assign rank2_comp  = cycle_cnt[1];
    assign rank2_stall = stall_cnt[1];
    assign rank3_pc    = pc_record[2];
    assign rank3_comp  = cycle_cnt[2];
    assign rank3_stall = stall_cnt[2];
    assign rank4_pc    = pc_record[3];
    assign rank4_comp  = cycle_cnt[3];
    assign rank4_stall = stall_cnt[3];
    assign rank5_pc    = pc_record[4];
    assign rank5_comp  = cycle_cnt[4];
    assign rank5_stall = stall_cnt[4];
    /**/
    
endmodule
