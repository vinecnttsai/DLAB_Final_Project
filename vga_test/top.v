`timescale 1ns / 1ps

module top(
    input sys_clk,
    input sys_rst_n,
    input left_btn,
    input right_btn,
    input jump_btn,
    output hsync,
    output vsync,
    output [11:0] rgb
    );
    

//-----------------------------------localparam-----------------------------------

    //-----------Sequence debug parameters-----------
    localparam SEQ_LEN = 16;
    localparam SEQ_DIGITS = SEQ_LEN / 4 + 1; // 1 for sign digit
    localparam SEQ_NUM = 20;
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
    localparam CHAR_WIDTH_X = 32;
    localparam CHAR_WIDTH_Y = 32;
    //-----------Character parameters-----------

    //-----------Screen parameters-----------
    localparam SCREEN_WIDTH = 10;
    localparam SMOOTH_FACTOR = 7; // Max = 7
    localparam SCREEN_N = 25600000 >>> (SMOOTH_FACTOR >>> 1);
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

//-----------------------------------Signal-----------------------------------

//--------------VGA signals----------------
    wire [9:0] w_x, w_y;
    wire w_p_tick, w_video_on;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
//--------------VGA signals----------------

//-----------------Button debug signals----------------
    wire left_btn_posedge, right_btn_posedge, jump_btn_posedge;
    wire debounced_left_btn, debounced_right_btn, debounced_jump_btn;
    reg debounced_left_btn_d, debounced_right_btn_d, debounced_jump_btn_d;
    reg [SEQ_LEN - 1:0] left_btn_cnt, right_btn_cnt, jump_btn_cnt;
//-----------------Button debug signals----------------

//---------------Character signals----------------
    wire [SIGNED_PHY_WIDTH-1:0] out_pos_x, out_pos_y, out_vel_x, out_vel_y, out_acc_x, out_acc_y;
    wire [7:0] out_jump_cnt;
    wire [3:0] out_state;
    wire [2:0] out_collision_type;
    wire [1:0] out_fall_to_ground, out_on_ground;
    wire [SIGNED_PHY_WIDTH-1:0] out_dis_to_ob;
    wire [1:0] out_row_detect;
    wire [$clog2(OBSTACLE_NUM+2):0] out_ob_detect;
    wire out_left_btn_posedge, out_right_btn_posedge, out_jump_btn_posedge;
    wire [1:0] out_face;
    wire [3:0] out_print_state; // TODO: print character state
//---------------Character signals----------------

//--------------Obstacle signals----------------
    wire signed [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_abs_pos_x, obstacle_abs_pos_y;
    wire [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_relative_pos_x, obstacle_relative_pos_y;
    wire [OBSTACLE_NUM * BLOCK_LEN_WIDTH - 1:0] obstacle_block_width;
    wire [4:0] camera_y;
//--------------Obstacle signals----------------

//--------------Debug Sequence signals----------------
    wire [SEQ_LEN - 1:0] debug_padded_sig [SEQ_NUM - 1:0];
    wire [SEQ_NUM * UNIT_SEQ_WIDTH - 1:0] debug_sig;
//--------------Debug Sequence signals----------------


//-----------------------------------Signal-----------------------------------


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

    fq_div #(.N(SCREEN_N)) fq_div1( // slowest clock : 100000000
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(debug_char_clk)
    );
//-----------------------------------Sequence debug-----------------------------------


//-----------------------------------Button debug-----------------------------------
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
        end else if(debounced_left_btn_d && debug_char_clk) begin
            left_btn_cnt <= left_btn_cnt + 1;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            right_btn_cnt <= 0;
        end else if(debounced_right_btn_d && debug_char_clk) begin
            right_btn_cnt <= right_btn_cnt + 1;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            jump_btn_cnt <= 0;
        end else if(debounced_jump_btn_d && debug_char_clk) begin
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

//-----------------------------------Block generator-----------------------------------
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
        .abs_char_y(out_pos_y),
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
//-----------------------------------Block generator-----------------------------------


//-----------------------------------Character-----------------------------------
    // TODO: add debug signal : out_print_state, current block type, current camera y
    // TODO: check obstacle collision logic
    // Note: clock condition has changed
    // Note: paramter, signal must be connected, check twice
    // Note: check all screen_width, phy_width
    tb_character #( 
        .SMOOTH_FACTOR(SMOOTH_FACTOR),
        .PHY_WIDTH(PHY_WIDTH),
        .SIGNED_PHY_WIDTH(SIGNED_PHY_WIDTH),
        .PIXEL_WIDTH(PIXEL_WIDTH),
        //-----------Map parameters-----------
        .MAP_WIDTH_X(MAP_WIDTH_X),
        //.MAP_WIDTH_Y(MAP_WIDTH_Y),
        .MAP_X_OFFSET(MAP_X_OFFSET),
        .MAP_Y_OFFSET(MAP_Y_OFFSET),
        .WALL_WIDTH(WALL_WIDTH),
        //-----------Character parameters-----------
        .CHAR_WIDTH_X(CHAR_WIDTH_X),
        .CHAR_WIDTH_Y(CHAR_WIDTH_Y),
        //-----------Obstacle parameters-----------
        .OBSTACLE_NUM(OBSTACLE_NUM),
        .OBSTACLE_WIDTH(OBSTACLE_WIDTH),
        .BLOCK_LEN_WIDTH(BLOCK_LEN_WIDTH)
        ) char (
        .sys_clk(sys_clk),
        .character_clk(debug_char_clk),
        .sys_rst_n(sys_rst_n),
        .left_btn(debounced_left_btn_d),
        .right_btn(debounced_right_btn_d),
        .jump_btn(debounced_jump_btn_d),
        .obstacle_abs_pos_x(obstacle_abs_pos_x),
        .obstacle_abs_pos_y(obstacle_abs_pos_y),
        .obstacle_block_width(obstacle_block_width),
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
        .out_on_ground(out_on_ground),
        .out_dis_to_ob(out_dis_to_ob),
        .out_row_detect(out_row_detect),
        .out_ob_detect(out_ob_detect),
        .out_left_btn_posedge(out_left_btn_posedge),
        .out_right_btn_posedge(out_right_btn_posedge),
        .out_jump_btn_posedge(out_jump_btn_posedge)
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
                .sys_clk(sys_clk),
                .sys_rst_n(sys_rst_n),
                .video_on(w_video_on),
                .camera_y(camera_y),
                .x(w_x),
                .y(w_y),
                .char_abs_x(out_pos_x[PHY_WIDTH - 1:0]),
                .char_abs_y(out_pos_y[PHY_WIDTH - 1:0]),
                .obstacle_abs_pos_x(obstacle_abs_pos_x),
                .obstacle_abs_pos_y(obstacle_abs_pos_y),
                .obstacle_block_width(obstacle_block_width),
                .debug_seq(debug_sig),
                .rgb(rgb_next));
//-----------------------------------Pixel generator-----------------------------------


//-----------------------------------Debug variables-----------------------------------

    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_1 ( .seq(cnt), .padded_seq(debug_padded_sig[0]) );
    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_2 ( .seq(left_btn_cnt), .padded_seq(debug_padded_sig[1]) );
    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_3 ( .seq(right_btn_cnt), .padded_seq(debug_padded_sig[2]) );
    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_4 ( .seq(jump_btn_cnt), .padded_seq(debug_padded_sig[3]) );
    //-----------------signed signal----------------- 1 for sign digit
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_5 ( .seq(out_pos_x), .padded_seq(debug_padded_sig[4]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_6 ( .seq(out_pos_y), .padded_seq(debug_padded_sig[5]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_7 ( .seq(out_vel_x), .padded_seq(debug_padded_sig[6]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_8 ( .seq(out_vel_y), .padded_seq(debug_padded_sig[7]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_9 ( .seq(out_acc_x), .padded_seq(debug_padded_sig[8]) );
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_10( .seq(out_acc_y), .padded_seq(debug_padded_sig[9]) );
    pad_sign #(.seq_len(2), .SEQ_LEN(SEQ_LEN)) pad_11( .seq(out_face), .padded_seq(debug_padded_sig[10]) );
    //-----------------unsigned signal----------------- 1 for sign digit
    pad_sign #(.seq_len(7 + 1), .SEQ_LEN(SEQ_LEN)) pad_12( .seq(out_jump_cnt), .padded_seq(debug_padded_sig[11]) );
    pad_sign #(.seq_len(3 + 1), .SEQ_LEN(SEQ_LEN)) pad_13( .seq(out_state), .padded_seq(debug_padded_sig[12]) );
    pad_sign #(.seq_len(2 + 1), .SEQ_LEN(SEQ_LEN)) pad_14( .seq(out_collision_type), .padded_seq(debug_padded_sig[13]) );
    pad_sign #(.seq_len(1 + 1), .SEQ_LEN(SEQ_LEN)) pad_15( .seq(out_fall_to_ground), .padded_seq(debug_padded_sig[14]) );
    pad_sign #(.seq_len(1 + 1), .SEQ_LEN(SEQ_LEN)) pad_16( .seq(out_on_ground), .padded_seq(debug_padded_sig[15]) );
    //-----------------debug signal-----------------
    pad_sign #(.seq_len(SIGNED_PHY_WIDTH), .SEQ_LEN(SEQ_LEN)) pad_17( .seq(out_dis_to_ob), .padded_seq(debug_padded_sig[16]) );
    pad_sign #(.seq_len(1 + 1), .SEQ_LEN(SEQ_LEN)) pad_18( .seq(out_row_detect), .padded_seq(debug_padded_sig[17]) );
    pad_sign #(.seq_len($clog2(OBSTACLE_NUM+2) + 1), .SEQ_LEN(SEQ_LEN)) pad_19( .seq(out_ob_detect), .padded_seq(debug_padded_sig[18]) );
    pad_sign #(.seq_len(5 + 1), .SEQ_LEN(SEQ_LEN)) pad_20( .seq({1'b0, camera_y}), .padded_seq(debug_padded_sig[19]) );
    
    
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