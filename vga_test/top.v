`timescale 1ns / 1ps

// Frogger Remake
// By: David J. Marion aka FPGA Dude
// Last Edit: 3/10/2022
// Information:
// Drawing the Frogger background screen based on Atari screenshot.
// Commented sections of code to be added later as game is developed.

module top(
    input sys_clk,       // Basys 3 oscillator
    input sys_rst_n,        // btnC
    input left_btn,         // btnL
    input right_btn,        // btnR
    input jump_btn,         // btnD
    output hsync,           // to VGA port
    output vsync,           // to VGA port
    output [11:0] rgb       // to DAC, to VGA port
    );
    
//-----------------------------------VGA signals-----------------------------------
    wire [9:0] w_x, w_y;
    wire w_p_tick, w_video_on, sys_rst_n;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
//-----------------------------------VGA signals-----------------------------------

//-----------------------------------localparam-----------------------------------

    //-----------Sequence debug parameters-----------
    localparam SEQ_LEN = 16;
    localparam SEQ_DIGITS = SEQ_LEN / 4 + 1; // 1 for sign digit
    localparam SEQ_NUM = 16;
    localparam FONT_WIDTH = 8;
    localparam UNIT_SEQ_WIDTH = SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH;
    //-----------Sequence debug parameters-----------

    //-----------Pixel generator parameters-----------
    localparam PIXEL_WIDTH = 12;
    //-----------Pixel generator parameters-----------

    //-----------Map parameters-----------
    localparam MAP_WIDTH_X = 100;
    localparam MAP_WIDTH_Y = 100;
    localparam MAP_X_OFFSET = 270;
    localparam MAP_Y_OFFSET = 50;
    localparam WALL_WIDTH = 10;
    //-----------Map parameters-----------

    //-----------Character parameters-----------
    localparam CHAR_WIDTH_X = 32;
    localparam CHAR_WIDTH_Y = 32;
    //-----------Character parameters-----------

    //-----------Screen parameters-----------
    localparam SCREEN_WIDTH = 10;
    //-----------Screen parameters-----------

//-----------------------------------localparam-----------------------------------


//-----------------------------------Sequence debug-----------------------------------
    reg signed [SEQ_LEN - 1:0] cnt;
    wire debug_char_clk;

    always @(posedge debug_char_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            cnt <= 0;
        end else begin
            cnt <= cnt - 1;
        end
    end

    fq_div #(.N(100000000)) fq_div1(
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(debug_char_clk)
    );
//-----------------------------------Sequence debug-----------------------------------


//-----------------------------------Button debug-----------------------------------
    wire left_btn_posedge, right_btn_posedge, jump_btn_posedge;
    wire debounced_left_btn, debounced_right_btn, debounced_jump_btn;
    reg debounced_left_btn_d, debounced_right_btn_d, debounced_jump_btn_d;
    reg [SEQ_LEN - 1:0] left_btn_cnt, right_btn_cnt, jump_btn_cnt;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            debounced_left_btn_d <= 0;
            debounced_right_btn_d <= 0;
            debounced_jump_btn_d <= 0;
        end else begin
            debounced_left_btn_d <= debounced_left_btn;
            debounced_right_btn_d <= debounced_right_btn;
            debounced_jump_btn_d <= debounced_jump_btn;
        end
    end
    assign left_btn_posedge = debounced_left_btn && ~debounced_left_btn_d;
    assign right_btn_posedge = debounced_right_btn && ~debounced_right_btn_d;
    assign jump_btn_posedge = debounced_jump_btn && ~debounced_jump_btn_d;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            left_btn_cnt <= 0;
        end else if(left_btn_posedge) begin
            left_btn_cnt <= left_btn_cnt + 1;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            right_btn_cnt <= 0;
        end else if(right_btn_posedge) begin
            right_btn_cnt <= right_btn_cnt + 1;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            jump_btn_cnt <= 0;
        end else if(jump_btn_posedge) begin
            jump_btn_cnt <= jump_btn_cnt + 1;
        end
    end

    debounce db1(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .org(left_btn),
        .debounced(debounced_left_btn)
    );

    debounce db2(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .org(right_btn),
        .debounced(debounced_right_btn)
    );

    debounce db3(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .org(jump_btn),
        .debounced(debounced_jump_btn)
    );
//-----------------------------------Button debug-----------------------------------

//-----------------------------------Character-----------------------------------
    wire [SCREEN_WIDTH:0] out_pos_x, out_pos_y, out_vel_x, out_vel_y, out_acc_x, out_acc_y, out_jump_cnt;
    wire [1:0] out_face;
    tb_character #( 
        .PHY_WIDTH(SCREEN_WIDTH),
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .MAP_WIDTH_X(MAP_WIDTH_X),
        .MAP_WIDTH_Y(MAP_WIDTH_Y),
        .MAP_X_OFFSET(MAP_X_OFFSET),
        .MAP_Y_OFFSET(MAP_Y_OFFSET),
        .WALL_WIDTH(WALL_WIDTH),
        .CHAR_WIDTH_X(CHAR_WIDTH_X),
        .CHAR_WIDTH_Y(CHAR_WIDTH_Y) 
        ) char (
        .sys_clk(sys_clk),
        .character_clk(debug_char_clk),
        .sys_rst_n(sys_rst_n),
        .left_btn(debounced_left_btn),
        .right_btn(debounced_right_btn),
        .jump_btn(debounced_jump_btn),
        .out_pos_x(out_pos_x),
        .out_pos_y(out_pos_y),
        .out_vel_x(out_vel_x),
        .out_vel_y(out_vel_y),
        .out_acc_x(out_acc_x),
        .out_acc_y(out_acc_y),
        .out_jump_cnt(out_jump_cnt),
        .out_face(out_face),
        .out_state(out_state),
        .out_collision_type(out_collision_type),
        .out_fall_to_ground(out_fall_to_ground),
        .out_on_ground(out_on_ground)
    );
//-----------------------------------Character-----------------------------------


//-----------------------------------Map-----------------------------------

//-----------------------------------Map-----------------------------------
    

//-----------------------------------VGA controller-----------------------------------
    vga_controller vga( .sys_clk(sys_clk),
                        .sys_rst_n(sys_rst_n),
                        .video_on(w_video_on),
                        .p_tick(w_p_tick),
                        .hsync(hsync),
                        .vsync(vsync),
                        .x(w_x),
                        .y(w_y));
//-----------------------------------VGA controller-----------------------------------


//-----------------------------------Pixel generator-----------------------------------
    pixel_gen #(.SEQ_DIGITS(SEQ_DIGITS),
                .SEQ_NUM(SEQ_NUM),
                .PIXEL_WIDTH(PIXEL_WIDTH),
                .FONT_WIDTH(FONT_WIDTH),
                .CHAR_WIDTH_X(CHAR_WIDTH_X),
                .CHAR_WIDTH_Y(CHAR_WIDTH_Y),
                .MAP_WIDTH_X(MAP_WIDTH_X),
                .MAP_WIDTH_Y(MAP_WIDTH_Y),
                .MAP_X_OFFSET(MAP_X_OFFSET),
                .MAP_Y_OFFSET(MAP_Y_OFFSET)
                ) pg (
                .sys_clk(sys_clk),
                .sys_rst_n(sys_rst_n),
                .video_on(w_video_on),
                .x(w_x),
                .y(w_y),
                .char_x(out_pos_x[SCREEN_WIDTH - 1:0]),
                .char_y(out_pos_y[SCREEN_WIDTH - 1:0]),
                .debug_seq(debug_sig),
                .rgb(rgb_next));
//-----------------------------------Pixel generator-----------------------------------


//-----------------------------------Debug variables-----------------------------------
wire [SEQ_LEN - 1:0] debug_padded_sig [SEQ_NUM - 1:0];
wire [SEQ_NUM * UNIT_SEQ_WIDTH - 1:0] debug_sig;

    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_1 ( .seq(cnt), .padded_seq(debug_padded_sig[0]) );
    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_2 ( .seq(left_btn_cnt), .padded_seq(debug_padded_sig[1]) );
    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_3 ( .seq(right_btn_cnt), .padded_seq(debug_padded_sig[2]) );
    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_4 ( .seq(jump_btn_cnt), .padded_seq(debug_padded_sig[3]) );
    //-----------------signed signal----------------- 1 for sign digit
    pad_sign #(.seq_len(SCREEN_WIDTH + 1), .SEQ_LEN(SEQ_LEN)) pad_5 ( .seq(out_pos_x), .padded_seq(debug_padded_sig[4]) );
    pad_sign #(.seq_len(SCREEN_WIDTH + 1), .SEQ_LEN(SEQ_LEN)) pad_6 ( .seq(out_pos_y), .padded_seq(debug_padded_sig[5]) );
    pad_sign #(.seq_len(SCREEN_WIDTH + 1), .SEQ_LEN(SEQ_LEN)) pad_7 ( .seq(out_vel_x), .padded_seq(debug_padded_sig[6]) );
    pad_sign #(.seq_len(SCREEN_WIDTH + 1), .SEQ_LEN(SEQ_LEN)) pad_8 ( .seq(out_vel_y), .padded_seq(debug_padded_sig[7]) );
    pad_sign #(.seq_len(SCREEN_WIDTH + 1), .SEQ_LEN(SEQ_LEN)) pad_9 ( .seq(out_acc_x), .padded_seq(debug_padded_sig[8]) );
    pad_sign #(.seq_len(SCREEN_WIDTH + 1), .SEQ_LEN(SEQ_LEN)) pad_10( .seq(out_acc_y), .padded_seq(debug_padded_sig[9]) );
    pad_sign #(.seq_len(2), .SEQ_LEN(SEQ_LEN)) pad_11( .seq(out_face), .padded_seq(debug_padded_sig[10]) );
    //-----------------unsigned signal----------------- 1 for sign digit
    pad_sign #(.seq_len(7 + 1), .SEQ_LEN(SEQ_LEN)) pad_12( .seq(out_jump_cnt), .padded_seq(debug_padded_sig[11]) );
    pad_sign #(.seq_len(3 + 1), .SEQ_LEN(SEQ_LEN)) pad_13( .seq(out_state), .padded_seq(debug_padded_sig[12]) );
    pad_sign #(.seq_len(2 + 1), .SEQ_LEN(SEQ_LEN)) pad_14( .seq(out_collision_type), .padded_seq(debug_padded_sig[13]) );
    pad_sign #(.seq_len(1 + 1), .SEQ_LEN(SEQ_LEN)) pad_15( .seq(out_fall_to_ground), .padded_seq(debug_padded_sig[14]) );
    pad_sign #(.seq_len(1 + 1), .SEQ_LEN(SEQ_LEN)) pad_16( .seq(out_on_ground), .padded_seq(debug_padded_sig[15]) );
    // state : IDLE = 0, LEFT = 1, RIGHT = 2, CHARGE = 3, JUMP = 4, COLLISION = 5, FALL_TO_GROUND = 6;
    

    genvar i;
    generate
        for (i = 0; i < SEQ_NUM; i = i + 1) begin : debug_var
            debug_var #(.SEQ_LEN(SEQ_LEN), .PIXEL_WIDTH(PIXEL_WIDTH), .FONT_WIDTH(FONT_WIDTH)) debug_var_inst (
                .seq(debug_padded_sig[i]), .debug_seq(debug_sig[i * UNIT_SEQ_WIDTH +: UNIT_SEQ_WIDTH])
            );
        end
    endgenerate
//-----------------------------------Debug variables-----------------------------------

    // rgb buffer
    always @(posedge sys_clk) 
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule

module pad_sign #(parameter seq_len = 12, parameter SEQ_LEN = 16)(
    input [seq_len - 1:0] seq,
    output [SEQ_LEN - 1:0] padded_seq
);
assign padded_seq = {{(SEQ_LEN - seq_len){seq[seq_len - 1]}}, seq};

endmodule