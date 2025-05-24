`timescale 1ns / 1ps

module top_debug(
    input left,
    input right,
    input jump,
    input sys_clk,
    input sys_rst_n,
    //-----------vga output-----------
    output hsync,
    output vsync,
    output [11:0] rgb,
    //-----------7-segment display-----------
    output CA,
    output CB,
    output CC,
    output CD,
    output CE,
    output CF,
    output CG,
    output DP,
    output [7:0] AN
);

//-----------------------------------localparam-----------------------------------

    //-----------Pixel generator parameters-----------
    localparam PIXEL_WIDTH = 12;
    //-----------Pixel generator parameters-----------

    //-----------Sequence debug parameters-----------
    localparam SEQ_LEN = 20;
    localparam SEQ_DIGITS = (SEQ_LEN >>> 2) + 1; // 1 for sign digit
    localparam SEQ_NUM = 6;
    localparam FONT_WIDTH = 8;
    //-----------Sequence debug parameters-----------

    //-----------Map parameters-----------
    localparam MAP_WIDTH_X = 480;
    localparam MAP_X_OFFSET = 140;
    localparam MAP_Y_OFFSET = 0;
    localparam WALL_WIDTH = 10;
    localparam WALL_HEIGHT = 20;
    //-----------Map parameters-----------

    //-----------Character parameters-----------
    localparam CHAR_WIDTH_X = 42;
    localparam CHAR_WIDTH_Y = 50;
    //-----------Character parameters-----------

    //-----------Screen parameters-----------
    localparam SCREEN_WIDTH = 10;
    //-----------Screen parameters-----------

    //-----------Character parameters-----------
    localparam PHY_WIDTH = 16; // 2 ^ 16 = 65536
    localparam SIGNED_PHY_WIDTH = PHY_WIDTH + 1;
    localparam SMOOTH_FACTOR = 8; // Max = 8
    localparam SCREEN_N = 25600000 >>> (SMOOTH_FACTOR >>> 1); // 31.25 Hz
    //-----------Character parameters-----------

    //-----------Camera parameters-----------
    localparam CAMERA_WIDTH = 6;
    localparam MAX_CAMERA_Y = (1 << CAMERA_WIDTH) - 1; // max 63 levels
    //-----------Camera parameters-----------

    //-----------Obstacle parameters-----------
    localparam OBSTACLE_NUM = 7;
    localparam OBSTACLE_WIDTH = 10;
    localparam OBSTACLE_HEIGHT = 20;
    localparam BLOCK_WIDTH = 480;
    localparam BLOCK_LEN_WIDTH = 4; // max 15
    //-----------Obstacle parameters-----------

    //-----------Button parameters-----------
    localparam BTN_NUM = 3;

    localparam LEFT_BTN = 0;
    localparam RIGHT_BTN = 1;
    localparam JUMP_BTN = 2;
    //-----------Button parameters-----------

//-----------------------------------localparam-----------------------------------

//-----------------------------------Signal-----------------------------------

//--------------VGA signals----------------
    wire [SCREEN_WIDTH-1:0] x, y;
    wire p_tick, video_on;
    reg [PIXEL_WIDTH-1:0] rgb_reg;
    wire [PIXEL_WIDTH-1:0] rgb_next;
//--------------VGA signals----------------

//-----------------Button signals----------------
    reg [SIGNED_PHY_WIDTH-1:0] abs_camera_y;
    wire [BTN_NUM-1:0] btn;
    wire [BTN_NUM-1:0] debounced_btn;
    reg [BTN_NUM-1:0] debounced_btn_d;
    wire [BTN_NUM-1:0] btn_posedge;
//-----------------Button signals----------------

//---------------Output Sequence signals----------------
    wire [SIGNED_PHY_WIDTH-1:0] out_pos_x;
    wire [SIGNED_PHY_WIDTH-1:0] out_pos_y;
    wire [SIGNED_PHY_WIDTH-1:0] out_vel_x;
    wire [SIGNED_PHY_WIDTH-1:0] out_vel_y;
    wire [PHY_WIDTH-1:0] out_fall_cnt;
    wire [PHY_WIDTH-1:0] out_jump_cnt;
    reg [PHY_WIDTH-1:0] game_time;
//---------------Output Sequence signals----------------

//---------------Character signals----------------
    wire [2:0] char_display_id;
    wire [1:0] out_face;
//---------------Character signals----------------

//--------------Obstacle signals----------------
    wire signed [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_abs_pos_x;
    wire signed [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_abs_pos_y;
    wire [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_relative_pos_x;
    wire [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_relative_pos_y;
    wire [OBSTACLE_NUM * BLOCK_LEN_WIDTH - 1:0] obstacle_block_width;
    wire [CAMERA_WIDTH-1:0] camera_y;
    wire [3:0] cur_block_type;
//--------------Obstacle signals----------------

//--------------Debug Sequence signals----------------
    wire [SEQ_LEN * SEQ_NUM - 1:0] bcd_seq;
//--------------Debug Sequence signals----------------


//-----------------------------------Signal-----------------------------------

//-----------------------------------Input Button-----------------------------------
    assign btn[LEFT_BTN] = left;
    assign btn[RIGHT_BTN] = right;
    assign btn[JUMP_BTN] = jump;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            debounced_btn_d <= 0;
        end else begin
            debounced_btn_d <= debounced_btn;
        end
    end
    genvar i;
    generate
        for (i = 0; i < BTN_NUM; i = i + 1) begin
            assign btn_posedge[i] = debounced_btn[i] & ~debounced_btn_d[i];
        end
    endgenerate

    assign debounced_btn[LEFT_BTN] = left;
    assign debounced_btn[RIGHT_BTN] = right;
    assign debounced_btn[JUMP_BTN] = jump;
    genvar j;
    generate
        for (j = 0; j < BTN_NUM; j = j + 1) begin
            debounce db(
                .sys_clk(sys_clk),
                .sys_rst_n(sys_rst_n),
                .org(btn[j]),
                .debounced()
            );
        end
    endgenerate
//-----------------------------------Debug Mode-----------------------------------

//-----------------------------------Character clock-----------------------------------
    wire char_clk;
    wire game_clk;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            game_time <= 0;
        end else if (game_clk) begin
            game_time <= game_time + 1;
        end
    end

    fq_div #(.N(2)) fq_div1( // 100 MHz -> 1 Hz
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(game_clk)
    );

    fq_div #(.N(2)) fq_div2(
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(char_clk)
    );
//-----------------------------------Character clock-----------------------------------

//-----------------------------------Character---------------------------------------
character #( 
        .SMOOTH_FACTOR(SMOOTH_FACTOR),
        .PHY_WIDTH(PHY_WIDTH),
        .SIGNED_PHY_WIDTH(SIGNED_PHY_WIDTH),
        .PIXEL_WIDTH(PIXEL_WIDTH),
        //-----------Map parameters-----------
        .MAP_WIDTH_X(MAP_WIDTH_X),
        .MAP_X_OFFSET(MAP_X_OFFSET),
        .MAP_Y_OFFSET(MAP_Y_OFFSET),
        .WALL_WIDTH(WALL_WIDTH),
        .WALL_HEIGHT(WALL_HEIGHT),
        //-----------Character parameters-----------
        .CHAR_WIDTH_X(CHAR_WIDTH_X),
        .CHAR_WIDTH_Y(CHAR_WIDTH_Y),
        //-----------Obstacle parameters-----------
        .OBSTACLE_NUM(OBSTACLE_NUM),
        .OBSTACLE_WIDTH(OBSTACLE_WIDTH),
        .OBSTACLE_HEIGHT(OBSTACLE_HEIGHT),
        .BLOCK_LEN_WIDTH(BLOCK_LEN_WIDTH)
        ) char (
        .sys_clk(sys_clk),
        .character_clk(char_clk),
        .sys_rst_n(sys_rst_n),
        .left_btn(debounced_btn[LEFT_BTN]),
        .right_btn(debounced_btn[RIGHT_BTN]),
        .jump_btn(debounced_btn[JUMP_BTN]),
        .obstacle_abs_pos_x(obstacle_abs_pos_x),
        .obstacle_abs_pos_y(obstacle_abs_pos_y),
        .obstacle_block_width(obstacle_block_width),
        .out_pos_x(out_pos_x),
        .out_pos_y(out_pos_y),
        .out_vel_x(out_vel_x),
        .out_vel_y(out_vel_y),
        .char_display_id(char_display_id),
        .out_jump_cnt(out_jump_cnt),
        .out_face(out_face),
        .out_fall_cnt(out_fall_cnt)
    );
//-----------------------------------Character---------------------------------------



//-----------------------------------Obstacle-----------------------------------
    block_gen #(
        .PHY_WIDTH(PHY_WIDTH),
        .BLOCK_WIDTH(BLOCK_WIDTH),
        .PLATFORM_NUM_PER_BLOCK(OBSTACLE_NUM),
        .BLOCK_LEN_WIDTH(BLOCK_LEN_WIDTH),
        .CAMERA_WIDTH(CAMERA_WIDTH),
        .BLOCK_NUM(7),
        .MAX_JUMP_HEIGHT(100),
        .MAX_JUMP_WIDTH(100)
    ) block_gen_inst(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .abs_camera_y(out_pos_y),
        .camera_y(camera_y),
        .plat_relative_x(obstacle_relative_pos_x),
        .plat_relative_y(obstacle_relative_pos_y),
        .plat_len(obstacle_block_width),
        .cur_block_type(cur_block_type),
        .block_switch(),
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
                        .video_on(video_on),
                        .p_tick(p_tick),
                        .hsync(hsync),
                        .vsync(vsync),
                        .x(x),
                        .y(y));
//-----------------------------------VGA controller-----------------------------------

//-----------------------------------Debug variables-----------------------------------
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_1 ( .seq({1'b0, game_time}), .padded_seq(bcd_seq[SEQ_LEN * 0 +: SEQ_LEN]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_2 ( .seq(out_pos_x), .padded_seq(bcd_seq[SEQ_LEN * 1 +: SEQ_LEN]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_3 ( .seq(out_pos_y), .padded_seq(bcd_seq[SEQ_LEN * 2 +: SEQ_LEN]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_4 ( .seq(out_vel_x), .padded_seq(bcd_seq[SEQ_LEN * 3 +: SEQ_LEN]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_5 ( .seq(out_vel_y), .padded_seq(bcd_seq[SEQ_LEN * 4 +: SEQ_LEN]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_6 ( .seq({1'b0, out_fall_cnt}), .padded_seq(bcd_seq[SEQ_LEN * 5 +: SEQ_LEN]) );

//-----------------------------------Debug variables-----------------------------------

//-----------------------------------Charge bar-----------------------------------
    charge_bar_controller #(
        .PHY_WIDTH(PHY_WIDTH),
        .SEQ_LEN(SEQ_LEN)
    ) charge_bar_controller_inst(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .charge_bar(out_jump_cnt),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .DP(DP),
        .AN(AN)
    );
//-----------------------------------Charge bar-----------------------------------


//-----------------------------------Pixel generator-----------------------------------
    pixel_gen #(
                .PIXEL_WIDTH(PIXEL_WIDTH),
                .FONT_WIDTH(FONT_WIDTH),
                //-----------Sequence debug parameters-----------
                .BCD_SEQ_LEN(SEQ_LEN),
                .BCD_SEQ_DIGITS(SEQ_DIGITS),
                .BCD_SEQ_NUM(SEQ_NUM),
                //-----------Block parameters-----------
                .BLOCK_WIDTH(BLOCK_WIDTH),
                //-----------Map parameters-----------
                .MAP_WIDTH_X(MAP_WIDTH_X),
                .MAP_X_OFFSET(MAP_X_OFFSET),
                .MAP_Y_OFFSET(MAP_Y_OFFSET),
                .WALL_WIDTH(WALL_WIDTH),
                .WALL_HEIGHT(WALL_HEIGHT),
                //-----------Character parameters-----------
                .CHAR_WIDTH_X(CHAR_WIDTH_X),
                .CHAR_WIDTH_Y(CHAR_WIDTH_Y),
                //-----------Obstacle parameters-----------
                .OBSTACLE_NUM(OBSTACLE_NUM),
                .OBSTACLE_WIDTH(OBSTACLE_WIDTH),
                .OBSTACLE_HEIGHT(OBSTACLE_HEIGHT),
                .BLOCK_LEN_WIDTH(BLOCK_LEN_WIDTH),
                 //-----------Screen parameters-----------
                .SCREEN_WIDTH(SCREEN_WIDTH),
                //-----------Physical parameters-----------
                .PHY_WIDTH(PHY_WIDTH),
                .CAMERA_WIDTH(CAMERA_WIDTH)
                ) pg (
                .sys_clk(sys_clk),
                .sys_rst_n(sys_rst_n),
                .video_on(video_on),
                .camera_y(camera_y),
                .x(x),
                .y(y),
                .char_abs_x(out_pos_x[PHY_WIDTH-1:0]),
                .char_abs_y(out_pos_y[PHY_WIDTH-1:0]),
                .char_display_id(char_display_id),
                .char_face(out_face),
                .obstacle_abs_pos_x(obstacle_abs_pos_x),
                .obstacle_abs_pos_y(obstacle_abs_pos_y),
                .obstacle_block_width(obstacle_block_width),
                .bcd_seq(bcd_seq),
                .rgb(rgb_next)
    );
//-----------------------------------Pixel generator-----------------------------------


    // rgb buffer
    always @(posedge sys_clk) 
        if(p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule

module pad_sign #(parameter seq_len = 12, parameter SEQ_LEN = 20)(
    input [seq_len - 1:0] seq,
    output [SEQ_LEN - 1:0] padded_seq
);
assign padded_seq = {{(SEQ_LEN - seq_len){seq[seq_len - 1]}}, seq};

endmodule