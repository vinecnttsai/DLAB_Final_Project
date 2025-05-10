`timescale 1ns / 1ps

module pixel_gen #(
    //-----------Sequence debug parameters-----------
    parameter SEQ_DIGITS = 4,
    parameter SEQ_NUM = 16,
    parameter PIXEL_WIDTH = 12,
    parameter FONT_WIDTH = 8,
    parameter UNIT_SEQ_WIDTH = SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH,
    //-----------Map parameters-----------
    parameter MAP_WIDTH_X = 100,
    parameter MAP_WIDTH_Y = 100,
    parameter MAP_X_OFFSET = 270, // start position of map
    parameter MAP_Y_OFFSET = 50,
    //-----------Character parameters-----------
    parameter CHAR_WIDTH_X = 32, // width of character
    parameter CHAR_WIDTH_Y = 32, // height of character
    //-----------Screen parameters-----------
    parameter SCREEN_WIDTH = 10
    )(
    input sys_clk,
    input sys_rst_n,
    input video_on,     // from VGA controller
    input [SCREEN_WIDTH - 1:0] x,      // from VGA controller
    input [SCREEN_WIDTH - 1:0] y,      // from VGA controller
    input [SCREEN_WIDTH - 1:0] char_x, // from character
    input [SCREEN_WIDTH - 1:0] char_y, // from character
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
    localparam SEQ_INTERVAL = 5;
    //----------------------------------------------------------------------------
    
    //------------------------------Pixel Location Status Signals------------------------------
    wire debug_seq_on [SEQ_NUM - 1:0];
    wire map_on;
    wire char_on;
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
    wire [SCREEN_WIDTH - 1:0] char_y_rom;
    wire [SCREEN_WIDTH - 1:0] char_x_rom;
    assign char_y_rom = y - char_y;
    assign char_x_rom = x - char_x;
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
            end else if(map_on) begin
                rgb = map_rgb;
            end else if(char_on) begin
                rgb = char_rgb;
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
    IDLE_CHAR #(
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .CHAR_WIDTH_X(CHAR_WIDTH_X),
        .CHAR_WIDTH_Y(CHAR_WIDTH_Y)
    ) char_inst(
        .char_x_rom(char_x_rom),
        .char_y_rom(char_y_rom),
        .char_on(char_on),
        .rgb(char_rgb)
    );
    //-----------------------------------------------------------------

endmodule
