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
    
    // Internal Signals
    wire [9:0] w_x, w_y;
    wire w_p_tick, w_video_on, sys_rst_n;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;

    localparam PIXEL_WIDTH = 12;
    localparam FONT_WIDTH = 8;

//-----------------------------------Sequence debug-----------------------------------
    localparam SEQ_LEN = 16;
    reg [SEQ_LEN - 1:0] cnt;
    wire debug_clk;

    always @(posedge debug_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
        end
    end

    fq_div #(.N(10000000)) fq_div1(
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(debug_clk)
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
    wire [9:0] out_pos_x, out_pos_y, out_vel_x, out_vel_y, out_acc_x, out_acc_y, out_jump_cnt;
    wire [1:0] out_face;
    tb_character #( .GROUND_POS_Y(50) ) char (
        .character_clk(character_clk),
        .sys_rst_n(sys_rst_n),
        .left_btn(debounced_left_btn),
        .right_btn(debounced_right_btn),
        .jump_btn(debounced_jump_btn),
        .map(map),
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
    pixel_gen #(.SEQ_DIGITS(SEQ_LEN / 4)) pg(       //.sys_clk(sys_clk),
                        .video_on(w_video_on),
                        .x(w_x),
                        .y(w_y),
                        .debug_seq1(debug_cnt),
                        .debug_seq2(debug_left_btn_cnt),
                        .debug_seq3(debug_right_btn_cnt),
                        .debug_seq4(debug_jump_btn_cnt),
                        .debug_seq5(debug_out_pos_x),
                        .debug_seq6(debug_out_pos_y),
                        .debug_seq7(debug_out_vel_x),
                        .debug_seq8(debug_out_vel_y),
                        .debug_seq9(debug_out_acc_x),
                        .debug_seq10(debug_out_acc_y),
                        .debug_seq11(debug_out_jump_cnt),
                        .debug_seq12(debug_out_face),
                        .debug_seq13(debug_out_state),
                        .debug_seq14(debug_out_collision_type),
                        .debug_seq15(debug_out_fall_to_ground),
                        .debug_seq16(debug_out_on_ground),
                        .rgb(rgb_next));
//-----------------------------------Pixel generator-----------------------------------


//-----------------------------------Debug variables-----------------------------------
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_cnt;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_left_btn_cnt;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_right_btn_cnt;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_jump_btn_cnt;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_pos_x;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_pos_y;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_vel_x;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_vel_y;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_acc_x;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_acc_y;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_jump_cnt;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_face;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_state;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_collision_type;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_fall_to_ground;
wire [SEQ_LEN * FONT_WIDTH * FONT_WIDTH * PIXEL_WIDTH - 1:0] debug_out_on_ground;

    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var1(
        .seq(cnt),
        .debug_seq(debug_cnt)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var2(
        .seq(left_btn_cnt),
        .debug_seq(debug_left_btn_cnt)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var3(
        .seq(right_btn_cnt),
        .debug_seq(debug_right_btn_cnt)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var4(
        .seq(jump_btn_cnt),
        .debug_seq(debug_jump_btn_cnt)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var5(
        .seq({6'd0, out_pos_x}),
        .debug_seq(debug_out_pos_x)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var6(
        .seq({6'd0, out_pos_y}),
        .debug_seq(debug_out_pos_y)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var7(
        .seq({6'd0, out_vel_x}),
        .debug_seq(debug_out_vel_x)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var8(
        .seq({6'd0, out_vel_y}),
        .debug_seq(debug_out_vel_y)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var9(
        .seq({6'd0, out_acc_x}),
        .debug_seq(debug_out_acc_x)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var10(
        .seq({6'd0, out_acc_y}),
        .debug_seq(debug_out_acc_y)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var11(
        .seq({6'd0, out_jump_cnt}),
        .debug_seq(debug_out_jump_cnt)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var12(
        .seq({14'd0, out_face}),
        .debug_seq(debug_out_face)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var13(
        .seq({13'd0, out_state}),
        .debug_seq(debug_out_state)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var14(
        .seq({14'd0, out_collision_type}),
        .debug_seq(debug_out_collision_type)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var15(
        .seq({15'd0, out_fall_to_ground}),
        .debug_seq(debug_out_fall_to_ground)
    );
    debug_var #(.SEQ_LEN(SEQ_LEN)) debug_var16(
        .seq({15'd0, out_on_ground}),
        .debug_seq(debug_out_on_ground)
    );
//-----------------------------------Debug variables-----------------------------------

    // rgb buffer
    always @(posedge sys_clk) 
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule