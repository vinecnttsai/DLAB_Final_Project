`timescale 1ns / 1ps

module top(
    input sw,
    input up,
    input down,
    input sys_clk,
    input sys_rst_n,
    //---------vga-------------
    output hsync,
    output vsync,
    output [11:0] rgb,
    //---------7-segment display---------
    output CA, CB, CC, CD, CE, CF, CG,
    output DP,
    output [7:0] AN
    );
    
//-----------------------------------VGA signals-----------------------------------
    wire [9:0] x, y;
    wire p_tick, video_on;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
//-----------------------------------VGA signals-----------------------------------

//-----------------------------------localparam-----------------------------------

    //-----------Pixel generator parameters-----------
    localparam PIXEL_WIDTH = 12;
    //-----------Pixel generator parameters-----------

    //-----------Sequence debug parameters-----------
    localparam SEQ_LEN = 20;
    localparam SEQ_DIGITS = (SEQ_LEN >>> 2) + 1; // 1 for sign digit
    localparam SEQ_NUM = 5;
    localparam FONT_WIDTH = 8;
    //-----------Sequence debug parameters-----------

    //-----------Map parameters-----------
    localparam MAP_WIDTH_X = 480;
    localparam MAP_X_OFFSET = 140;
    localparam MAP_Y_OFFSET = 0;
    localparam WALL_WIDTH = 10;
    //-----------Map parameters-----------

    //-----------Character parameters-----------
    localparam CHAR_WIDTH_X = 42;
    localparam CHAR_WIDTH_Y = 50;
    //-----------Character parameters-----------

    //-----------Screen parameters-----------
    localparam SCREEN_WIDTH = 10;
    //-----------Screen parameters-----------

    //-----------Physical parameters-----------
    localparam PHY_WIDTH = 16; // 2 ^ 16 = 65536
    localparam SIGNED_PHY_WIDTH = PHY_WIDTH + 1;
    localparam CAMERA_WIDTH = 6;
    localparam MAX_CAMERA_Y = (1 << CAMERA_WIDTH) - 1; // max 63 levels
    //-----------Physical parameters-----------

    //-----------Obstacle parameters-----------
    localparam OBSTACLE_NUM = 7;
    localparam OBSTACLE_WIDTH = 10;
    localparam BLOCK_WIDTH = 480;
    localparam BLOCK_LEN_WIDTH = 4; // max 15
    //-----------Obstacle parameters-----------

//-----------------------------------localparam-----------------------------------

//-----------------------------------Obstacle signals-----------------------------------
    wire signed [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_abs_pos_x, obstacle_abs_pos_y;
    wire [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_relative_pos_x, obstacle_relative_pos_y;
    wire [OBSTACLE_NUM * BLOCK_LEN_WIDTH - 1:0] obstacle_block_width;
    wire [CAMERA_WIDTH - 1:0] camera_y;
    wire [3:0] cur_block_type;
//-----------------------------------Obstacle signals-----------------------------------

//-----------------------------------Debug Mode-----------------------------------
    reg [SIGNED_PHY_WIDTH-1:0] debug_y;
    wire debounced_up_btn, debounced_down_btn;
    reg debounced_up_btn_d, debounced_down_btn_d;
    wire up_btn_posedge, down_btn_posedge;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            debounced_up_btn_d <= 0;
            debounced_down_btn_d <= 0;
        end else begin
            debounced_up_btn_d <= debounced_up_btn;
            debounced_down_btn_d <= debounced_down_btn;
        end
    end
    assign up_btn_posedge = debounced_up_btn && ~debounced_up_btn_d;
    assign down_btn_posedge = debounced_down_btn && ~debounced_down_btn_d;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            debug_y <= 10;
        end else if (up_btn_posedge) begin
            debug_y <= (camera_y >= MAX_CAMERA_Y) ? debug_y : debug_y + BLOCK_WIDTH;
        end else if (down_btn_posedge) begin
            debug_y <= (camera_y == 0) ? 10 : debug_y - BLOCK_WIDTH;
        end
    end

    debounce db1(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .org(up),
        .debounced(debounced_up_btn)
    );

    debounce db2(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .org(down),
        .debounced(debounced_down_btn)
    );
//-----------------------------------Debug Mode-----------------------------------


//-----------------------------------Sequence debug-----------------------------------
    reg signed [SEQ_LEN - 1:0] cnt;
    reg signed [SEQ_LEN - 1:0] cnt_2;
    wire debug_char_clk;
    wire debug_char_clk_2;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            cnt <= 1;
        end else if (debug_char_clk) begin
            cnt <= (cnt == 500) ? 1 : cnt + 1;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            cnt_2 <= 0;
        end else if (debug_char_clk_2) begin
            cnt_2 <= cnt_2 - 1;
        end
    end

    fq_div #(.N(10000000)) fq_div1( // 10000000
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(debug_char_clk)
    );

    fq_div #(.N(100000)) fq_div2( // 100000
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(debug_char_clk_2)
    );
//-----------------------------------Sequence debug-----------------------------------


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
        .abs_char_y(debug_y),
        .camera_y(camera_y),
        .plat_relative_x(obstacle_relative_pos_x),
        .plat_relative_y(obstacle_relative_pos_y),
        .plat_len(obstacle_block_width),
        .block_switch(),
        .cur_block_type(cur_block_type),
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

//-----------------------------------Charge bar-----------------------------------
    charge_bar_controller #(
        .PHY_WIDTH(PHY_WIDTH),
        .SEQ_LEN(SEQ_LEN)
    ) charge_bar_controller_inst(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .charge_bar(cnt[PHY_WIDTH-1:0]),
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

//-----------------------------------Debug variables-----------------------------------
wire [SEQ_LEN * SEQ_NUM - 1:0] debug_sig;

    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_1 ( .seq(cnt), .padded_seq(debug_sig[SEQ_LEN * 0 +: SEQ_LEN]) );
    pad_sign #(.seq_len(6 + 1), .SEQ_LEN(SEQ_LEN)) pad_2 ( .seq({1'b0, camera_y}), .padded_seq(debug_sig[SEQ_LEN * 1 +: SEQ_LEN]) );
    pad_sign #(.seq_len(SEQ_LEN), .SEQ_LEN(SEQ_LEN)) pad_3 ( .seq(cnt_2), .padded_seq(debug_sig[SEQ_LEN * 2 +: SEQ_LEN]) );
    pad_sign #(.seq_len(4 + 1), .SEQ_LEN(SEQ_LEN)) pad_4 ( .seq({1'b0, cur_block_type}), .padded_seq(debug_sig[SEQ_LEN * 3 +: SEQ_LEN]) );
    pad_sign #(.seq_len(CAMERA_WIDTH + 1), .SEQ_LEN(SEQ_LEN)) pad_5 ( .seq({1'b0, camera_y}), .padded_seq(debug_sig[SEQ_LEN * 4 +: SEQ_LEN]) );

//-----------------------------------Debug variables-----------------------------------


//-----------------------------------Pixel generator-----------------------------------
    pixel_gen #(
                .BCD_SEQ_LEN(SEQ_LEN),
                .BCD_SEQ_DIGITS(SEQ_DIGITS),
                .BCD_SEQ_NUM(SEQ_NUM),
                .PIXEL_WIDTH(PIXEL_WIDTH),
                .FONT_WIDTH(FONT_WIDTH),
                //-----------Block parameters-----------
                .BLOCK_WIDTH(BLOCK_WIDTH),
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
                .BLOCK_LEN_WIDTH(BLOCK_LEN_WIDTH),
                 //-----------Screen parameters-----------
                .SCREEN_WIDTH(SCREEN_WIDTH),
                //-----------Physical parameters-----------
                .PHY_WIDTH(PHY_WIDTH),
                .CAMERA_WIDTH(CAMERA_WIDTH)
                ) pg (
                .sw(sw),
                .sys_clk(sys_clk),
                .sys_rst_n(sys_rst_n),
                .video_on(video_on),
                .camera_y(camera_y),
                .x(x),
                .y(y),
                .char_abs_x(560),
                .char_abs_y(380),
                .obstacle_abs_pos_x(obstacle_abs_pos_x),
                .obstacle_abs_pos_y(obstacle_abs_pos_y),
                .obstacle_block_width(obstacle_block_width),
                .bcd_seq(debug_sig),
                .rgb(rgb_next));
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