`timescale 1ns / 1ps

module pixel_gen #(parameter SEQ_DIGITS = 4,
                   parameter PIXEL_WIDTH = 12,
                   parameter FONT_WIDTH = 8,
                   parameter MAP_WIDTH_X = 100,
                   parameter MAP_WIDTH_Y = 100,
                   parameter MAP_X = 270, // start position of map
                   parameter MAP_Y = 50,
                   parameter CHAR_WIDTH_X = 16, // width of character
                   parameter CHAR_WIDTH_Y = 16
    )(
    input sys_clk,
    input sys_rst_n,
    input video_on,     // from VGA controller
    input [9:0] x,      // from VGA controller
    input [9:0] y,      // from VGA controller
    input [9:0] char_x, // from character
    input [9:0] char_y, // from character
    output reg [11:0] rgb,   // to VGA port
    //------------------------------data signals------------------------------
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq1,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq2,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq3,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq4,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq5,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq6,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq7,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq8,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq9,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq10,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq11,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq12,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq13,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq14,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq15,
    input [SEQ_DIGITS * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq16
    //------------------------------map signals------------------------------
    //input [MAP_X * MAP_Y - 1:0] map,
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
    wire debug_seq1_on;
    wire debug_seq2_on;
    wire debug_seq3_on;
    wire debug_seq4_on;
    wire debug_seq5_on;
    wire debug_seq6_on;
    wire debug_seq7_on;
    wire debug_seq8_on;
    wire debug_seq9_on;
    wire debug_seq10_on;
    wire debug_seq11_on;
    wire debug_seq12_on;
    wire debug_seq13_on;
    wire debug_seq14_on;
    wire debug_seq15_on;
    wire debug_seq16_on;
    wire map_on;
    wire char_on;
    //----------------------------------------------------------------------------------------

    //-----------------------------Debug Sequence Position Signals-----------------------------
    wire [9:0] debug_seq1_pos_y = 0;
    wire [9:0] debug_seq2_pos_y = FONT_WIDTH + SEQ_INTERVAL;
    wire [9:0] debug_seq3_pos_y = FONT_WIDTH * 2 + SEQ_INTERVAL * 2;
    wire [9:0] debug_seq4_pos_y = FONT_WIDTH * 3 + SEQ_INTERVAL * 3;
    wire [9:0] debug_seq5_pos_y = FONT_WIDTH * 4 + SEQ_INTERVAL * 4;
    wire [9:0] debug_seq6_pos_y = FONT_WIDTH * 5 + SEQ_INTERVAL * 5;
    wire [9:0] debug_seq7_pos_y = FONT_WIDTH * 6 + SEQ_INTERVAL * 6;
    wire [9:0] debug_seq8_pos_y = FONT_WIDTH * 7 + SEQ_INTERVAL * 7;
    wire [9:0] debug_seq9_pos_y = FONT_WIDTH * 8 + SEQ_INTERVAL * 8;
    wire [9:0] debug_seq10_pos_y = FONT_WIDTH * 9 + SEQ_INTERVAL * 9;
    wire [9:0] debug_seq11_pos_y = FONT_WIDTH * 10 + SEQ_INTERVAL * 10;
    wire [9:0] debug_seq12_pos_y = FONT_WIDTH * 11 + SEQ_INTERVAL * 11;
    wire [9:0] debug_seq13_pos_y = FONT_WIDTH * 12 + SEQ_INTERVAL * 12;
    wire [9:0] debug_seq14_pos_y = FONT_WIDTH * 13 + SEQ_INTERVAL * 13;
    wire [9:0] debug_seq15_pos_y = FONT_WIDTH * 14 + SEQ_INTERVAL * 14;
    wire [9:0] debug_seq16_pos_y = FONT_WIDTH * 15 + SEQ_INTERVAL * 15;
    //----------------------------------------------------------------------------------------  

    //-----------------------------Debug Sequence Y Position Signals-----------------------------
    wire [9:0] debug_seq1_y = y - debug_seq1_pos_y;
    wire [9:0] debug_seq2_y = y - debug_seq2_pos_y;
    wire [9:0] debug_seq3_y = y - debug_seq3_pos_y;
    wire [9:0] debug_seq4_y = y - debug_seq4_pos_y;
    wire [9:0] debug_seq5_y = y - debug_seq5_pos_y;
    wire [9:0] debug_seq6_y = y - debug_seq6_pos_y;
    wire [9:0] debug_seq7_y = y - debug_seq7_pos_y;
    wire [9:0] debug_seq8_y = y - debug_seq8_pos_y;
    wire [9:0] debug_seq9_y = y - debug_seq9_pos_y;
    wire [9:0] debug_seq10_y = y - debug_seq10_pos_y;
    wire [9:0] debug_seq11_y = y - debug_seq11_pos_y;
    wire [9:0] debug_seq12_y = y - debug_seq12_pos_y;
    wire [9:0] debug_seq13_y = y - debug_seq13_pos_y;
    wire [9:0] debug_seq14_y = y - debug_seq14_pos_y;
    wire [9:0] debug_seq15_y = y - debug_seq15_pos_y;
    wire [9:0] debug_seq16_y = y - debug_seq16_pos_y;
    wire [9:0] map_y = y - MAP_Y;
    wire [9:0] map_x = x - MAP_X;
    wire [9:0] char_y_rom = y - char_y;
    wire [9:0] char_x_rom = x - char_x;
    //----------------------------------------------------------------------------------------
    
    //------------------------------Drivers for Status Signals------------------------------
    assign debug_seq1_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq1_pos_y) && (y < debug_seq1_pos_y + FONT_WIDTH));
    assign debug_seq2_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq2_pos_y) && (y < debug_seq2_pos_y + FONT_WIDTH));
    assign debug_seq3_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq3_pos_y) && (y < debug_seq3_pos_y + FONT_WIDTH));
    assign debug_seq4_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq4_pos_y) && (y < debug_seq4_pos_y + FONT_WIDTH));
    assign debug_seq5_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq5_pos_y) && (y < debug_seq5_pos_y + FONT_WIDTH));
    assign debug_seq6_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq6_pos_y) && (y < debug_seq6_pos_y + FONT_WIDTH));
    assign debug_seq7_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq7_pos_y) && (y < debug_seq7_pos_y + FONT_WIDTH));
    assign debug_seq8_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq8_pos_y) && (y < debug_seq8_pos_y + FONT_WIDTH));
    assign debug_seq9_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq9_pos_y) && (y < debug_seq9_pos_y + FONT_WIDTH));
    assign debug_seq10_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq10_pos_y) && (y < debug_seq10_pos_y + FONT_WIDTH));
    assign debug_seq11_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq11_pos_y) && (y < debug_seq11_pos_y + FONT_WIDTH));
    assign debug_seq12_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq12_pos_y) && (y < debug_seq12_pos_y + FONT_WIDTH));
    assign debug_seq13_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq13_pos_y) && (y < debug_seq13_pos_y + FONT_WIDTH));
    assign debug_seq14_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq14_pos_y) && (y < debug_seq14_pos_y + FONT_WIDTH));
    assign debug_seq15_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq15_pos_y) && (y < debug_seq15_pos_y + FONT_WIDTH));
    assign debug_seq16_on = ((x >= 0) && (x < SEQ_DIGITS * FONT_WIDTH) && (y >= debug_seq16_pos_y) && (y < debug_seq16_pos_y + FONT_WIDTH));
    assign map_on = ((x >= MAP_X) && (x < MAP_X + MAP_WIDTH_X) && (y >= MAP_Y) && (y < MAP_Y + MAP_WIDTH_Y));
    assign char_on = ((x >= char_x) && (x < char_x + CHAR_WIDTH_X) && (y >= char_y) && (y < char_y + CHAR_WIDTH_Y));
    //----------------------------------------------------------------------------------------
    
    // Set RGB output value based on status signals
    always @(*) begin 
        if(~video_on) begin
            rgb = BLACK;
        end else begin
            
            if(debug_seq1_on) begin
                rgb = debug_seq1[(debug_seq1_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq2_on) begin
                rgb = debug_seq2[(debug_seq2_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq3_on) begin
                rgb = debug_seq3[(debug_seq3_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq4_on) begin
                rgb = debug_seq4[(debug_seq4_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq5_on) begin
                rgb = debug_seq5[(debug_seq5_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq6_on) begin
                rgb = debug_seq6[(debug_seq6_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq7_on) begin
                rgb = debug_seq7[(debug_seq7_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq8_on) begin
                rgb = debug_seq8[(debug_seq8_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq9_on) begin
                rgb = debug_seq9[(debug_seq9_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq10_on) begin
                rgb = debug_seq10[(debug_seq10_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq11_on) begin
                rgb = debug_seq11[(debug_seq11_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq12_on) begin
                rgb = debug_seq12[(debug_seq12_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq13_on) begin
                rgb = debug_seq13[(debug_seq13_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq14_on) begin
                rgb = debug_seq14[(debug_seq14_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq15_on) begin
                rgb = debug_seq15[(debug_seq15_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(debug_seq16_on) begin
                rgb = debug_seq16[(debug_seq16_y * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
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
    Map map_inst(
        .x(map_x),
        .y(map_y),
        .map_on(map_on),
        .rgb(map_rgb)
    );
    //-----------------------------------------------------------------

    //------------------------------Character--------------------------------
    IDLE_CHAR char_inst(
        .char_x_rom(char_x_rom),
        .char_y_rom(char_y_rom),
        .char_on(char_on),
        .rgb(char_rgb)
    );
    //-----------------------------------------------------------------

endmodule
