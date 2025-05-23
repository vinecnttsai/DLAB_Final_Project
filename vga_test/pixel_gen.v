`timescale 1ns / 1ps
// camera_y is the y coordinate of the camera, is TODO
// obstacle_print_module
module pixel_gen #(
    //-----------Sequence debug parameters-----------
    parameter SEQ_DIGITS = 6,
    parameter SEQ_NUM = 8,
    parameter PIXEL_WIDTH = 12,
    parameter FONT_WIDTH = 8,
    parameter UNIT_SEQ_WIDTH = SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH,
    //-----------Block parameters-----------
    parameter BLOCK_WIDTH = 480,
    //-----------Map parameters-----------
    parameter MAP_WIDTH_X = 480,
    //parameter MAP_WIDTH_Y = 100,
    parameter MAP_X_OFFSET = 120, // start position of map (640 - 480) / 2
    parameter MAP_Y_OFFSET = 0,
    //-----------Character parameters-----------
    parameter CHAR_WIDTH_X = 32, // width of character
    parameter CHAR_WIDTH_Y = 32, // height of character
    //-----------Obstacle parameters-----------
    parameter OBSTACLE_NUM = 10,
    parameter OBSTACLE_WIDTH = 10,
    parameter OBSTACLE_HEIGHT = 20,
    parameter BLOCK_LEN_WIDTH = 4, // max 15
    //-----------Screen parameters-----------
    parameter SCREEN_WIDTH = 10,
    //-----------Physical parameters-----------
    parameter PHY_WIDTH = 16
    )(
    input sys_clk,
    input sys_rst_n,
    input video_on,     // from VGA controller
    input [4:0] camera_y,
    input [SCREEN_WIDTH - 1:0] x,      // from VGA controller
    input [SCREEN_WIDTH - 1:0] y,
    input [PHY_WIDTH-1:0] char_abs_x, // Absolute position
    input [PHY_WIDTH-1:0] char_abs_y, // Absolute position
    input [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_abs_pos_x, // Absolute position
    input [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_abs_pos_y, // Absolute position
    input [OBSTACLE_NUM * BLOCK_LEN_WIDTH - 1:0] obstacle_block_width,
    input [2:0] char_display_id,
    input [1:0] char_face,
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
    wire [PHY_WIDTH-1:0] camera_offset;
    assign camera_offset = camera_y * BLOCK_WIDTH;
    //----------------------------------------------------------------------------
    
    //------------------------------RGB Signals------------------------------
    reg [PIXEL_WIDTH - 1:0] char_rgb;
    wire [PIXEL_WIDTH - 1:0] map_rgb;
    wire [PIXEL_WIDTH - 1:0] obstacle_rgb;
    //----------------------------------------------------------------------------
    
    //------------------------------Pixel Location Status Signals------------------------------
    wire [SEQ_NUM - 1:0] debug_seq_on;
    wire map_on;
    wire char_on;
    wire [OBSTACLE_NUM - 1:0] obstacle_on;
    //----------------------------------------------------------------------------------------

    //-----------------------------Debug Sequence Absolute Position Signals-----------------------------
    wire [SCREEN_WIDTH-1:0] debug_seq_pos_y [SEQ_NUM - 1:0];
    genvar i;
    generate
        for(i = 0; i < SEQ_NUM; i = i + 1) begin : debug_seq_pos
            assign debug_seq_pos_y[i] = i * (FONT_WIDTH + SEQ_INTERVAL);
        end
    endgenerate
    //----------------------------------------------------------------------------------------  

    //-----------------------------Debug Sequence Relative Position Signals-----------------------------
    wire [SCREEN_WIDTH-1:0] debug_seq_y [SEQ_NUM - 1:0];
    genvar j;
    generate
        for(j = 0; j < SEQ_NUM; j = j + 1) begin : debug_seq_y_pos
            assign debug_seq_y[j] = y - debug_seq_pos_y[j];
        end
    endgenerate
    //----------------------------------------------------------------------------------------

    //-----------------------------Map ROM Position Signals-----------------------------
    wire [PHY_WIDTH-1:0] map_y;
    wire [PHY_WIDTH-1:0] map_x;
    assign map_y = y + camera_offset - MAP_Y_OFFSET;
    assign map_x = x - MAP_X_OFFSET;
    //----------------------------------------------------------------------------------------

    //-----------------------------Character ROM Position Signals-----------------------------
    wire [PHY_WIDTH - 1:0] char_y_rom;
    wire [PHY_WIDTH - 1:0] char_x_rom;
    assign char_y_rom = y + camera_offset - char_abs_y;
    assign char_x_rom = x - char_abs_x;
    //----------------------------------------------------------------------------------------

    //-----------------------------Obstacle ROM Position Signals-----------------------------
    wire [PHY_WIDTH - 1:0] obstacle_y_rom [OBSTACLE_NUM - 1:0];
    wire [PHY_WIDTH - 1:0] obstacle_x_rom [OBSTACLE_NUM - 1:0];
    genvar l;
    generate
        for(l = 0; l < OBSTACLE_NUM; l = l + 1) begin : obstacle_pos
            assign obstacle_y_rom[l] = y + camera_offset - obstacle_abs_pos_y[l*PHY_WIDTH +: PHY_WIDTH];
            assign obstacle_x_rom[l] = x - obstacle_abs_pos_x[l*PHY_WIDTH +: PHY_WIDTH];
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
    assign map_on = ((x >= MAP_X_OFFSET) && (x < MAP_X_OFFSET + MAP_WIDTH_X) && (y >= MAP_Y_OFFSET)); // && (y < MAP_Y_OFFSET + MAP_WIDTH_Y));
    assign char_on = ((x >= char_abs_x) && (x < char_abs_x + CHAR_WIDTH_X) && (y >= char_abs_y - camera_offset) && (y < char_abs_y + CHAR_WIDTH_Y - camera_offset));
    genvar m;
    generate
        for(m = 0; m < OBSTACLE_NUM; m = m + 1) begin: ob_on
            assign obstacle_on[m] = ((x >= obstacle_abs_pos_x[m*PHY_WIDTH +: PHY_WIDTH]) && (x < obstacle_abs_pos_x[m*PHY_WIDTH +: PHY_WIDTH] + obstacle_block_width[m*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] * OBSTACLE_WIDTH) && (y >= obstacle_abs_pos_y[m*PHY_WIDTH +: PHY_WIDTH] - camera_offset) && (y < obstacle_abs_pos_y[m*PHY_WIDTH +: PHY_WIDTH] + OBSTACLE_HEIGHT - camera_offset));
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
            end else if(char_on) begin
                rgb = char_rgb; //char_rgb, remember to change back
            end else if(|obstacle_on) begin // not all blank
                rgb = 12'h000;
            end else if(map_on) begin
                rgb = map_rgb;
            end else begin
                rgb = WHITE;
            end
        end
    end

    //------------------------------Map--------------------------------
    Map #(
        .PHY_WIDTH(PHY_WIDTH),
        .MAP_WIDTH_X(MAP_WIDTH_X)
    ) map_inst(
        .map_x(map_x),
        .map_y(map_y),
        .map_on(map_on),
        .rgb(map_rgb)
    );
    //-----------------------------------------------------------------

    //------------------------------Test Character--------------------------------
    // IDLE_DIS_1 = 0, IDLE_DIS_2 = 1, CHARGE_DIS = 2, JUMP_UP_DIS = 3, JUMP_DOWN_DIS = 4, FALL_TO_GROUND_DIS = 5;
    (* rom_style = "block" *)
    always @(*) begin
        case({char_face, char_display_id})
            6'b01_000: char_rgb = BLACK;
            6'b11_000: char_rgb = TEAL;
            6'b01_001: char_rgb = GRAY;
            6'b11_001: char_rgb = LIME;
            6'b01_010: char_rgb = RED;
            6'b11_010: char_rgb = AQUA;
            6'b01_011: char_rgb = YELLOW;
            6'b11_011: char_rgb = ORANGE;
            6'b01_100: char_rgb = BLUE;
            6'b11_100: char_rgb = PURPLE;
            6'b01_101: char_rgb = BROWN;
            6'b11_101: char_rgb = PINK;
            6'b01_110: char_rgb = MAROON;
            6'b11_110: char_rgb = OLIVE;
            default: char_rgb = WHITE;
        endcase
    end
    //------------------------------Character--------------------------------
    /* // TODO: disable first, fill character in all black first
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
    );*/
    //-----------------------------------------------------------------

    //------------------------------Obstacle-------------------------------- // TODO: write module for obstacle print
    /*OBSTACLE #(
        .OBSTACLE_NUM(OBSTACLE_NUM),
        .OBSTACLE_WIDTH(OBSTACLE_WIDTH),
        .OBSTACLE_HEIGHT(OBSTACLE_HEIGHT),
        .SCREEN_WIDTH(SCREEN_WIDTH),
    ) obstacle_inst(
        .obstacle_abs_pos_x(obstacle_abs_pos_x),
        .obstacle_abs_pos_y(obstacle_abs_pos_y),
        .obstacle_block_width(obstacle_block_width),
        .rgb(obstacle_rgb)
    );*/
    //-----------------------------------------------------------------

endmodule
