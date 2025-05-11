`timescale 1ns / 1ps
// camera_y is the y coordinate of the camera, is TODO
// obstacle_print_module
module pixel_gen #(
    //-----------Sequence debug parameters-----------
    parameter SEQ_DIGITS = 4,
    parameter SEQ_NUM = 16 + 1 + 17,
    parameter PIXEL_WIDTH = 12,
    parameter FONT_WIDTH = 8,
    parameter UNIT_SEQ_WIDTH = SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH,
    //-----------Block parameters-----------
    parameter BLOCK_WIDTH = 480,
    //-----------Map parameters-----------
    parameter MAP_WIDTH_X = 100,
    parameter MAP_WIDTH_Y = 100,
    parameter MAP_X_OFFSET = 270, // start position of map
    parameter MAP_Y_OFFSET = 50,
    //-----------Character parameters-----------
    parameter CHAR_WIDTH_X = 32, // width of character
    parameter CHAR_WIDTH_Y = 32, // height of character
    //-----------Obstacle parameters-----------
    parameter OBSTACLE_NUM = 10,
    parameter OBSTACLE_WIDTH = 10,
    //-----------Screen parameters-----------
    parameter SCREEN_WIDTH = 10,
    parameter PHY_WIDTH = 14
    )(
    input sys_clk,
    input sys_rst_n,
    input video_on,     // from VGA controller
    input [4:0] camera_y,
    input [SCREEN_WIDTH - 1:0] x,      // from VGA controller
    input [SCREEN_WIDTH - 1:0] y,      // from VGA controller
    input [PHY_WIDTH-1:0] char_x, // from character
    input [PHY_WIDTH-1:0] char_y, // from character
    input [PHY_WIDTH * OBSTACLE_NUM - 1:0] obstacle_pos_x,
    input [PHY_WIDTH * OBSTACLE_NUM - 1:0] obstacle_pos_y,
    input [PHY_WIDTH * OBSTACLE_NUM - 1:0] obstacle_block_width,
    output reg [PIXEL_WIDTH - 1:0] rgb,   // to VGA port
    //------------------------------data signals------------------------------
    input [SEQ_NUM * UNIT_SEQ_WIDTH - 1:0] debug_seq
    );
    
    //------------------------------RGB Color Values------------------------------
    localparam RED    = 12'h00F;
    localparam GREEN  = 12'h2A6;
    localparam BLUE   = 12'hA21;
    localparam YELLOW = 12'h5FF; 
    localparam BLACK  = 12'h000;
    localparam WHITE  = 12'hFFF;
    localparam ORANGE = 12'hF80;
    localparam PURPLE = 12'h808;
    localparam PINK   = 12'hF41;
    localparam GRAY   = 12'h841;
    localparam BROWN  = 12'h820;
    localparam CYAN   = 12'hFFE;
    localparam MAGENTA = 12'hF0F;
    localparam LIME   = 12'h7F7;
    localparam AQUA   = 12'h0FF;
    localparam LAVENDER = 12'hE6E;
    localparam TEAL   = 12'h088;
    localparam OLIVE  = 12'h880;
    localparam MAROON = 12'h800;
    //----------------------------------------------------------------------------

    //------------------------------Utility variables------------------------------
    localparam SEQ_INTERVAL = 3;
    //----------------------------------------------------------------------------

    //------------------------------Camera offset--------------------------------
    wire [PHY_WIDTH - 1:0] camera_offset;
    assign camera_offset = camera_y * BLOCK_WIDTH;
    //----------------------------------------------------------------------------
    
    //------------------------------RGB Signals------------------------------
    wire [PIXEL_WIDTH - 1:0] char_rgb;
    wire [PIXEL_WIDTH - 1:0] map_rgb;
    wire [PIXEL_WIDTH - 1:0] obstacle_rgb;
    //----------------------------------------------------------------------------
    
    //------------------------------Pixel Location Status Signals------------------------------
    wire [SEQ_NUM - 1:0] debug_seq_on;
    wire map_on;
    wire char_on;
    wire [OBSTACLE_NUM - 1:0] obstacle_on;
    //----------------------------------------------------------------------------------------

    //-----------------------------Debug Sequence Position Signals-----------------------------
    wire [SCREEN_WIDTH - 1:0] debug_seq_pos_y [SEQ_NUM - 1:0];
    genvar i;
    generate
        for(i = 0; i < SEQ_NUM; i = i + 1) begin : debug_seq_pos
            assign debug_seq_pos_y[i] = i * (FONT_WIDTH + SEQ_INTERVAL);
        end
    endgenerate
    //----------------------------------------------------------------------------------------  

    //-----------------------------Debug Sequence Y Position Signals-----------------------------
    wire [SCREEN_WIDTH - 1:0] debug_seq_y [SEQ_NUM - 1:0];
    genvar j;
    generate
        for(j = 0; j < SEQ_NUM; j = j + 1) begin : debug_seq_y_pos
            assign debug_seq_y[j] = y - debug_seq_pos_y[j];
        end
    endgenerate
    //----------------------------------------------------------------------------------------

    //-----------------------------Map Position Signals-----------------------------
    wire [SCREEN_WIDTH - 1:0] map_y;
    wire [SCREEN_WIDTH - 1:0] map_x;
    assign map_y = y - MAP_Y_OFFSET;
    assign map_x = x - MAP_X_OFFSET;
    //----------------------------------------------------------------------------------------

    //-----------------------------Character Position Signals-----------------------------
    wire [PHY_WIDTH - 1:0] char_y_rom;
    wire [PHY_WIDTH - 1:0] char_x_rom;
    assign char_y_rom = y - char_y;
    assign char_x_rom = x - char_x;
    //----------------------------------------------------------------------------------------

    //-----------------------------Obstacle Position Signals-----------------------------
    wire [PHY_WIDTH - 1:0] obstacle_y_rom [OBSTACLE_NUM - 1:0];
    wire [PHY_WIDTH - 1:0] obstacle_x_rom [OBSTACLE_NUM - 1:0];
    genvar l;
    generate
        for(l = 0; l < OBSTACLE_NUM; l = l + 1) begin : obstacle_pos
            assign obstacle_y_rom[l] = y - obstacle_pos_y[l];
            assign obstacle_x_rom[l] = x - obstacle_pos_x[l];
        end
    endgenerate
    //----------------------------------------------------------------------------------------
    
    //------------------------------Drivers for Status Signals------------------------------
    genvar k;
    generate
        for(k = 0; k < SEQ_NUM; k = k + 1) begin : debug_sequence_on
            assign debug_seq_on[k] = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq_pos_y[k]) && (y < debug_seq_pos_y[k] + FONT_WIDTH));
        end
    endgenerate
    assign map_on = ((x >= MAP_X_OFFSET) && (x < MAP_X_OFFSET + MAP_WIDTH_X) && (y >= MAP_Y_OFFSET) && (y < MAP_Y_OFFSET + MAP_WIDTH_Y));
    assign char_on = ((x >= char_x) && (x < char_x + CHAR_WIDTH_X) && (y >= char_y) && (y < char_y + CHAR_WIDTH_Y));
    genvar m;
    generate
        for(m = 0; m < OBSTACLE_NUM; m = m + 1) begin : obstacle_on
            assign obstacle_on[m] = ((x >= obstacle_x_rom[m]) && (x < obstacle_x_rom[m] + obstacle_block_width[m] * OBSTACLE_WIDTH) && (y >= obstacle_y_rom[m]) && (y < obstacle_y_rom[m] + OBSTACLE_WIDTH));
        end
    endgenerate
    //----------------------------------------------------------------------------------------
    
    // Set RGB output value based on status signals
    always @(*) begin 
        if(~video_on) begin
            rgb = BLACK;
        end else begin

            if(debug_seq_on[0]) begin
                rgb = debug_seq[0 * UNIT_SEQ_WIDTH + (debug_seq_y[0] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[1]) begin
                rgb = debug_seq[1 * UNIT_SEQ_WIDTH + (debug_seq_y[1] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[2]) begin
                rgb = debug_seq[2 * UNIT_SEQ_WIDTH + (debug_seq_y[2] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[3]) begin
                rgb = debug_seq[3 * UNIT_SEQ_WIDTH + (debug_seq_y[3] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[4]) begin
                rgb = debug_seq[4 * UNIT_SEQ_WIDTH + (debug_seq_y[4] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[5]) begin
                rgb = debug_seq[5 * UNIT_SEQ_WIDTH + (debug_seq_y[5] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[6]) begin
                rgb = debug_seq[6 * UNIT_SEQ_WIDTH + (debug_seq_y[6] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[7]) begin
                rgb = debug_seq[7 * UNIT_SEQ_WIDTH + (debug_seq_y[7] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[8]) begin
                rgb = debug_seq[8 * UNIT_SEQ_WIDTH + (debug_seq_y[8] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[9]) begin
                rgb = debug_seq[9 * UNIT_SEQ_WIDTH + (debug_seq_y[9] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[10]) begin
                rgb = debug_seq[10 * UNIT_SEQ_WIDTH + (debug_seq_y[10] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[11]) begin
                rgb = debug_seq[11 * UNIT_SEQ_WIDTH + (debug_seq_y[11] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[12]) begin
                rgb = debug_seq[12 * UNIT_SEQ_WIDTH + (debug_seq_y[12] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[13]) begin
                rgb = debug_seq[13 * UNIT_SEQ_WIDTH + (debug_seq_y[13] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[14]) begin
                rgb = debug_seq[14 * UNIT_SEQ_WIDTH + (debug_seq_y[14] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[15]) begin
                rgb = debug_seq[15 * UNIT_SEQ_WIDTH + (debug_seq_y[15] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[16]) begin
                rgb = debug_seq[16 * UNIT_SEQ_WIDTH + (debug_seq_y[16] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[17]) begin
                rgb = debug_seq[17 * UNIT_SEQ_WIDTH + (debug_seq_y[17] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[18]) begin
                rgb = debug_seq[18 * UNIT_SEQ_WIDTH + (debug_seq_y[18] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[19]) begin
                rgb = debug_seq[19 * UNIT_SEQ_WIDTH + (debug_seq_y[19] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[20]) begin
                rgb = debug_seq[20 * UNIT_SEQ_WIDTH + (debug_seq_y[20] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[21]) begin
                rgb = debug_seq[21 * UNIT_SEQ_WIDTH + (debug_seq_y[21] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[22]) begin
                rgb = debug_seq[22 * UNIT_SEQ_WIDTH + (debug_seq_y[22] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[23]) begin
                rgb = debug_seq[23 * UNIT_SEQ_WIDTH + (debug_seq_y[23] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[24]) begin
                rgb = debug_seq[24 * UNIT_SEQ_WIDTH + (debug_seq_y[24] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[25]) begin
                rgb = debug_seq[25 * UNIT_SEQ_WIDTH + (debug_seq_y[25] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[26]) begin
                rgb = debug_seq[26 * UNIT_SEQ_WIDTH + (debug_seq_y[26] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[27]) begin
                rgb = debug_seq[27 * UNIT_SEQ_WIDTH + (debug_seq_y[27] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[28]) begin
                rgb = debug_seq[28 * UNIT_SEQ_WIDTH + (debug_seq_y[28] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[29]) begin
                rgb = debug_seq[29 * UNIT_SEQ_WIDTH + (debug_seq_y[29] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[30]) begin
                rgb = debug_seq[30 * UNIT_SEQ_WIDTH + (debug_seq_y[30] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[31]) begin
                rgb = debug_seq[31 * UNIT_SEQ_WIDTH + (debug_seq_y[31] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[32]) begin
                rgb = debug_seq[32 * UNIT_SEQ_WIDTH + (debug_seq_y[32] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq_on[33]) begin
                rgb = debug_seq[33 * UNIT_SEQ_WIDTH + (debug_seq_y[33] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(obstacle_on > 0) begin // not all blank
                rgb = obstacle_rgb;
            end else if(char_on) begin
                rgb = YELLOW; //char_rgb, remember to change back
            end else if(map_on) begin
                rgb = map_rgb;
            end else begin
                rgb = WHITE;
            end
        end
    end

    //------------------------------Map--------------------------------
    Map #(
        .MAP_WIDTH_X(MAP_WIDTH_X),
        .MAP_WIDTH_Y(MAP_WIDTH_Y)
    ) map_inst(
        .map_x(map_x),
        .map_y(map_y),
        .map_on(map_on),
        .rgb(map_rgb)
    );
    //-----------------------------------------------------------------

    //------------------------------Character--------------------------------
    // TODO: disable first, fill character in all black first
    IDLE_CHAR #(
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .CHAR_WIDTH_X(CHAR_WIDTH_X),
        .CHAR_WIDTH_Y(CHAR_WIDTH_Y)
    ) char_inst(
        .char_x_rom(char_x_rom[SCREEN_WIDTH - 1:0]),
        .char_y_rom(char_y_rom[SCREEN_WIDTH - 1:0]),
        .char_on(char_on),
        .rgb(char_rgb)
    );
    //-----------------------------------------------------------------

    //------------------------------Obstacle-------------------------------- // TODO: write module for obstacle print
    OBSTACLE #(
        .OBSTACLE_NUM(OBSTACLE_NUM),
        .OBSTACLE_WIDTH(OBSTACLE_WIDTH),
        .SCREEN_WIDTH(SCREEN_WIDTH),
    ) obstacle_inst(
        .obstacle_pos_x(obstacle_pos_x),
        .obstacle_pos_y(obstacle_pos_y),
        .obstacle_block_width(obstacle_block_width),
        .rgb(obstacle_rgb)
    );
    //-----------------------------------------------------------------

endmodule
