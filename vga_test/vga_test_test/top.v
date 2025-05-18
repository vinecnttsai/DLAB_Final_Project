`timescale 1ns / 1ps

module top(
    input sw,
    input sys_clk,
    input sys_rst_n,
    input left_btn,
    input right_btn,
    input jump_btn,
    output hsync,
    output vsync,
    output [11:0] rgb
    );
    
//-----------------------------------VGA signals-----------------------------------
    wire [9:0] w_x, w_y;
    wire w_p_tick, w_video_on;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
//-----------------------------------VGA signals-----------------------------------

//-----------------------------------localparam-----------------------------------

    //-----------Sequence debug parameters-----------
    localparam SEQ_LEN = 16;
    localparam SEQ_DIGITS = SEQ_LEN / 4 + 1; // 1 for sign digit
    localparam SEQ_NUM = 1;
    localparam FONT_WIDTH = 8;
    localparam UNIT_SEQ_WIDTH = SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH;
    //-----------Sequence debug parameters-----------

    //-----------Pixel generator parameters-----------
    localparam PIXEL_WIDTH = 12;
    //-----------Pixel generator parameters-----------

    //-----------Map parameters-----------
    localparam MAP_WIDTH_X = 480;
    //localparam MAP_WIDTH_Y = 100;
    localparam MAP_X_OFFSET = 120; // (640 - 480) / 2
    localparam MAP_Y_OFFSET = 0;
    localparam WALL_WIDTH = 10;
    //-----------Map parameters-----------

    //-----------Character parameters-----------
    localparam CHAR_WIDTH_X = 42;
    localparam CHAR_WIDTH_Y = 52;
    //-----------Character parameters-----------

    //-----------Screen parameters-----------
    localparam SCREEN_WIDTH = 10;
    //-----------Screen parameters-----------

    //-----------Physical parameters-----------
    localparam PHY_WIDTH = 14; // 2 ^ 14 = 16384
    localparam SIGNED_PHY_WIDTH = PHY_WIDTH + 1;
    //-----------Physical parameters-----------

    //-----------Obstacle parameters-----------
    localparam OBSTACLE_NUM = 7;
    localparam OBSTACLE_WIDTH = 10;
    localparam BLOCK_WIDTH = 480;
    localparam BLOCK_LEN_WIDTH = 4; // max 15
    //-----------Obstacle parameters-----------

//-----------------------------------localparam-----------------------------------


//-----------------------------------Sequence debug-----------------------------------
    reg signed [SEQ_LEN - 1:0] cnt;
    wire debug_char_clk;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            cnt <= 0;
        end else if (debug_char_clk) begin
            cnt <= cnt - 1;
        end
    end

    fq_div #(.N(10000000)) fq_div1( // slowest clock : 100000000
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(debug_char_clk)
    );
//-----------------------------------Sequence debug-----------------------------------



//-----------------------------------Obstacle-----------------------------------
    wire signed [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_abs_pos_x, obstacle_abs_pos_y;
    wire [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_relative_pos_x, obstacle_relative_pos_y;
    wire [OBSTACLE_NUM * BLOCK_LEN_WIDTH - 1:0] obstacle_block_width;
    wire [4:0] camera_y;
    block_gen #(
        .PHY_WIDTH(PHY_WIDTH),
        .BLOCK_WIDTH(BLOCK_WIDTH),
        .PLATFORM_NUM_PER_BLOCK(OBSTACLE_NUM),
        .BLOCK_LEN_WIDTH(BLOCK_LEN_WIDTH),
        .BLOCK_NUM(7),
        .MAX_JUMP_HEIGHT(100),
        .MAX_JUMP_WIDTH(100)
    ) block_gen_inst(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .abs_char_y(0),
        .camera_y(camera_y),
        .plat_relative_x(obstacle_relative_pos_x),
        .plat_relative_y(obstacle_relative_pos_y),
        .plat_len(obstacle_block_width),
        .block_switch(),
        .cur_block_type(),
        .switch_up()
    );

    genvar k;
    generate
        for (k = 0; k < OBSTACLE_NUM; k = k + 1) begin : obstacle_abs_pos
            assign obstacle_abs_pos_x[k*PHY_WIDTH +: PHY_WIDTH] = obstacle_relative_pos_x[k*PHY_WIDTH +: PHY_WIDTH] + MAP_X_OFFSET;
            assign obstacle_abs_pos_y[k*PHY_WIDTH +: PHY_WIDTH] = obstacle_relative_pos_y[k*PHY_WIDTH +: PHY_WIDTH] + camera_y * BLOCK_WIDTH + MAP_Y_OFFSET;
        end
    endgenerate

//-----------------------------------Obstacle-----------------------------------


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
                //-----------Block parameters-----------
                .BLOCK_WIDTH(BLOCK_WIDTH),
                //-----------Map parameters-----------
                .MAP_WIDTH_X(MAP_WIDTH_X),
                //.MAP_WIDTH_Y(MAP_WIDTH_Y),
                .MAP_X_OFFSET(MAP_X_OFFSET),
                .MAP_Y_OFFSET(MAP_Y_OFFSET),
                //-----------Character parameters-----------
                .CHAR_WIDTH_X(CHAR_WIDTH_X),
                .CHAR_WIDTH_Y(CHAR_WIDTH_Y),
                //-----------Obstacle parameters-----------
                .OBSTACLE_NUM(OBSTACLE_NUM),
                .OBSTACLE_WIDTH(OBSTACLE_WIDTH),
                .BLOCK_LEN_WIDTH(BLOCK_LEN_WIDTH),
                 //-----------Screen parameters-----------
                .SCREEN_WIDTH(SCREEN_WIDTH),
                //-----------Physical parameters-----------
                .PHY_WIDTH(PHY_WIDTH)
                ) pg (
                .sw(sw),
                .sys_clk(sys_clk),
                .sys_rst_n(sys_rst_n),
                .video_on(w_video_on),
                .camera_y(camera_y),
                .x(w_x),
                .y(w_y),
                .char_abs_x(300),
                .char_abs_y(MAP_Y_OFFSET + WALL_WIDTH),
                .obstacle_abs_pos_x(obstacle_abs_pos_x),
                .obstacle_abs_pos_y(obstacle_abs_pos_y),
                .obstacle_block_width(obstacle_block_width),
                .debug_seq(debug_sig),
                .rgb(rgb_next));
//-----------------------------------Pixel generator-----------------------------------


//-----------------------------------Debug variables-----------------------------------
wire [SEQ_LEN - 1:0] debug_padded_sig [SEQ_NUM - 1:0];
wire [SEQ_NUM * UNIT_SEQ_WIDTH - 1:0] debug_sig;

    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_1 ( .seq(cnt), .padded_seq(debug_padded_sig[0]) );

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