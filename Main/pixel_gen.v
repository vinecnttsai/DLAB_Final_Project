`timescale 1ns / 1ps
// camera_y is the y coordinate of the camera, is TODO
// obstacle_print_module
module pixel_gen #(
    parameter PIXEL_WIDTH = 12,
    parameter FONT_WIDTH = 8,
    //-----------BCD Sequence parameters-----------
    parameter BCD_SEQ_LEN = 20,
    parameter BCD_SEQ_DIGITS = (BCD_SEQ_LEN >>> 2) + 1,
    parameter BCD_SEQ_NUM = 6,
    parameter BCD_SEQ_X_WIDTH = BCD_SEQ_DIGITS * FONT_WIDTH,
    //-----------ASCII Sequence parameters-----------
    parameter STRING_NUM = 7,
    parameter MAX_CHAR_NUM = 11,
    parameter CHAR_WIDTH = 5,
    parameter ASCII_SEQ_X_WIDTH = MAX_CHAR_NUM * FONT_WIDTH,
    //-----------Block parameters-----------
    parameter BLOCK_WIDTH = 480,
    //-----------Map parameters-----------
    parameter MAP_WIDTH_X = 480,
    parameter MAP_X_OFFSET = 140, // start position of map (640 - 480) / 2
    parameter MAP_Y_OFFSET = 0,
    parameter WALL_WIDTH = 10,
    parameter WALL_HEIGHT = 20,
    //-----------Character parameters-----------
    parameter CHAR_WIDTH_X = 42, // width of character
    parameter CHAR_WIDTH_Y = 50, // height of character
    //-----------Obstacle parameters-----------
    parameter OBSTACLE_NUM = 7,
    parameter OBSTACLE_WIDTH = 10,
    parameter OBSTACLE_HEIGHT = 20,
    parameter BLOCK_LEN_WIDTH = 4, // max 15
    //-----------Screen parameters-----------
    parameter SCREEN_WIDTH = 10,
    parameter CAMERA_WIDTH = 6,
    //-----------Physical parameters-----------
    parameter PHY_WIDTH = 16
    )(
    input sys_clk,
    input sys_rst_n,
    input video_on,     // from VGA controller
    input [CAMERA_WIDTH - 1:0] camera_y,
    input [SCREEN_WIDTH - 1:0] x,      // from VGA controller
    input [SCREEN_WIDTH - 1:0] y,
    //-----------Character signals-----------
    input [PHY_WIDTH-1:0] char_abs_x, // Absolute position
    input [PHY_WIDTH-1:0] char_abs_y, // Absolute position
    input [2:0] char_display_id,
    input [1:0] char_face,
    //-----------Obstacle signals-----------
    input [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_abs_pos_x, // Absolute position
    input [OBSTACLE_NUM * PHY_WIDTH - 1:0] obstacle_abs_pos_y, // Absolute position
    input [OBSTACLE_NUM * BLOCK_LEN_WIDTH - 1:0] obstacle_block_width,
    //------------------------------data signals------------------------------
    input [BCD_SEQ_NUM * BCD_SEQ_LEN - 1:0] bcd_seq,
        //-----------output signals-----------
    output reg [PIXEL_WIDTH - 1:0] rgb   // to VGA port
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
    localparam ASCII_OFFSET = BCD_SEQ_X_WIDTH;
    //----------------------------------------------------------------------------

    //------------------------------Camera offset--------------------------------
    wire [PHY_WIDTH-1:0] camera_offset;
    assign camera_offset = camera_y * BLOCK_WIDTH;
    //----------------------------------------------------------------------------
    
    //------------------------------RGB Signals------------------------------
    wire [PIXEL_WIDTH - 1:0] bcd_seq_rgb;
    wire [PIXEL_WIDTH - 1:0] ascii_seq_rgb;
    wire [PIXEL_WIDTH - 1:0] char_rgb;
    wire [PIXEL_WIDTH - 1:0] map_rgb;
    wire [PIXEL_WIDTH - 1:0] obstacle_rgb;
    wire [PIXEL_WIDTH - 1:0] background_rgb;
    reg [PIXEL_WIDTH - 1:0] others_rgb;
    //----------------------------------------------------------------------------
    
    //------------------------------Pixel Location Status Signals------------------------------
    wire [BCD_SEQ_NUM - 1:0] bcd_seq_on;
    wire bcd_seq_on_for_all;
    wire [$clog2(BCD_SEQ_NUM + 1) - 1:0] bcd_seq_on_id;

    wire [STRING_NUM - 1:0] ascii_seq_on;
    wire ascii_seq_on_for_all;
    wire [$clog2(STRING_NUM + 1) - 1:0] ascii_seq_on_id;

    wire map_on;
    wire char_on;

    wire [OBSTACLE_NUM - 1:0] obstacle_on;
    wire obstacle_on_for_all;
    wire [$clog2(OBSTACLE_NUM + 1) - 1:0] obstacle_on_id;

    wire background_on;
    //----------------------------------------------------------------------------------------

    //-----------------------------Sequence Absolute Position Signals-----------------------------
    wire [SCREEN_WIDTH-1:0] bcd_seq_y [BCD_SEQ_NUM - 1:0];
    wire [SCREEN_WIDTH-1:0] ascii_seq_y [STRING_NUM - 1:0];
    genvar i;
    generate
        for(i = 0; i < BCD_SEQ_NUM; i = i + 1) begin : bcd_seq_pos
            assign bcd_seq_y[i] = i * (FONT_WIDTH + SEQ_INTERVAL) + SEQ_INTERVAL;
        end
    endgenerate
    genvar j;
    generate
        for(j = 0; j < STRING_NUM; j = j + 1) begin : ascii_seq_pos
            assign ascii_seq_y[j] = j * (FONT_WIDTH + SEQ_INTERVAL) + SEQ_INTERVAL;
        end
    endgenerate
    //----------------------------------------------------------------------------------------  

    //-----------------------------Sequence Relative Position Signals-----------------------------
    wire [SCREEN_WIDTH-1:0] bcd_seq_y_rom [BCD_SEQ_NUM - 1:0];
    wire [SCREEN_WIDTH-1:0] ascii_seq_y_rom [STRING_NUM - 1:0];
    wire [SCREEN_WIDTH-1:0] bcd_seq_x_rom;
    wire [SCREEN_WIDTH-1:0] ascii_seq_x_rom;
    genvar p;
    generate
        for(p = 0; p < BCD_SEQ_NUM; p = p + 1) begin : bcd_seq_y_rom_pos
            assign bcd_seq_y_rom[p] = y - bcd_seq_y[p];
        end
    endgenerate
    genvar q;
    generate
        for(q = 0; q < STRING_NUM; q = q + 1) begin : ascii_seq_y_rom_pos
            assign ascii_seq_y_rom[q] = y - ascii_seq_y[q];
        end
    endgenerate
    assign bcd_seq_x_rom = x;
    assign ascii_seq_x_rom = x - ASCII_OFFSET;
    //----------------------------------------------------------------------------------------

    //-----------------------------Map Relative Position Signals-----------------------------
    wire [PHY_WIDTH-1:0] map_y;
    wire [PHY_WIDTH-1:0] map_x;
    assign map_y = y - MAP_Y_OFFSET;   // boundary does not count
    assign map_x = x - MAP_X_OFFSET;                   // boundary does not count
    //----------------------------------------------------------------------------------------

    //-----------------------------Character Relative Position Signals-----------------------------
    wire [PHY_WIDTH - 1:0] char_y_rom; // 要改成screen_width
    wire [PHY_WIDTH - 1:0] char_x_rom;
    assign char_y_rom = y + camera_offset - char_abs_y;
    assign char_x_rom = x - char_abs_x;
    //----------------------------------------------------------------------------------------

    //-----------------------------Obstacle Relative Position Signals-----------------------------
    wire [PHY_WIDTH-1 :0] obstacle_y_rom [OBSTACLE_NUM-1:0];
    wire [PHY_WIDTH-1 :0] obstacle_x_rom [OBSTACLE_NUM-1:0];
    genvar l;
    generate
        for(l = 0; l < OBSTACLE_NUM; l = l + 1) begin : obstacle_pos
            assign obstacle_y_rom[l] = y + camera_offset - obstacle_abs_pos_y[l*PHY_WIDTH +: PHY_WIDTH];
            assign obstacle_x_rom[l] = x - obstacle_abs_pos_x[l*PHY_WIDTH +: PHY_WIDTH];
        end
    endgenerate
    //----------------------------------------------------------------------------------------

    //-----------------------------Background Relative Position Signals-----------------------------
    localparam BACKGROUND_WIDTH = OBSTACLE_WIDTH <<< 2;
    wire [SCREEN_WIDTH-1:0] background_y_rom;
    wire [SCREEN_WIDTH-1:0] background_x_rom;
    assign background_y_rom = y % OBSTACLE_HEIGHT;
    assign background_x_rom = x % BACKGROUND_WIDTH; // every 16 obstacle 
    //----------------------------------------------------------------------------------------

    //-----------------------------Background Absolute Position Signals-----------------------------
    wire [PHY_WIDTH-1:0] background_abs_pos_y;
    wire [PHY_WIDTH-1:0] background_abs_pos_x;
    wire [PHY_WIDTH-1:0] background_block_abs_y;
    assign background_abs_pos_y = 478 + camera_offset;
    assign background_abs_pos_x = x / BACKGROUND_WIDTH;
    assign background_block_abs_y = y / OBSTACLE_HEIGHT + camera_offset;
    //----------------------------------------------------------------------------------------
    
    //------------------------------Drivers for Status Signals------------------------------
    genvar o;
    generate
        for(o = 0; o < BCD_SEQ_NUM; o = o + 1) begin : bcd_sequence_
            assign bcd_seq_on[o] = ((x >= 0) && (x < BCD_SEQ_X_WIDTH) && (y >= bcd_seq_y[o]) && (y < bcd_seq_y[o] + FONT_WIDTH));
        end
    endgenerate
    assign bcd_seq_on_for_all = |bcd_seq_on;
    N_decoder #(.N(BCD_SEQ_NUM)) n_decoder_inst_bcd(
        .in(bcd_seq_on),
        .out(bcd_seq_on_id)
    );

    genvar n;
    generate
        for(n = 0; n < STRING_NUM; n = n + 1) begin : ascii_sequence_
            assign ascii_seq_on[n] = ((x >= ASCII_OFFSET) && (x < ASCII_OFFSET + ASCII_SEQ_X_WIDTH) && (y >= ascii_seq_y[n]) && (y < ascii_seq_y[n] + FONT_WIDTH));
        end
    endgenerate
    assign ascii_seq_on_for_all = |ascii_seq_on;
    N_decoder #(.N(STRING_NUM)) n_decoder_inst_ascii(
        .in(ascii_seq_on),
        .out(ascii_seq_on_id)
    );
    

    assign map_on = ((x >= MAP_X_OFFSET) && (x < MAP_X_OFFSET + MAP_WIDTH_X) && (y >= MAP_Y_OFFSET));
    assign char_on = ((x >= char_abs_x) && (x < char_abs_x + CHAR_WIDTH_X) && (y >= char_abs_y - camera_offset) && (y < char_abs_y + CHAR_WIDTH_Y - camera_offset));


    genvar m;
    generate
        for(m = 0; m < OBSTACLE_NUM; m = m + 1) begin: ob_on
            assign obstacle_on[m] = ((x >= obstacle_abs_pos_x[m*PHY_WIDTH +: PHY_WIDTH]) && (x < obstacle_abs_pos_x[m*PHY_WIDTH +: PHY_WIDTH] + obstacle_block_width[m*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] * OBSTACLE_WIDTH) && (y >= obstacle_abs_pos_y[m*PHY_WIDTH +: PHY_WIDTH] - camera_offset) && (y < obstacle_abs_pos_y[m*PHY_WIDTH +: PHY_WIDTH] + OBSTACLE_HEIGHT - camera_offset));
        end
    endgenerate
    assign obstacle_on_for_all = |obstacle_on;
    N_decoder #(.N(OBSTACLE_NUM)) n_decoder_inst_obstacle(
        .in(obstacle_on),
        .out(obstacle_on_id)
    );

    assign background_on = video_on;
    //----------------------------------------------------------------------------------------
    
    // Set RGB output value based on status signals
    always @(*) begin 
        if(~video_on) begin
            rgb = BLACK;
        end else begin

            if(bcd_seq_on_for_all) begin
                rgb = bcd_seq_rgb;
            end else if(ascii_seq_on_for_all) begin
                rgb = ascii_seq_rgb;
            end else if(char_on) begin
                rgb = char_rgb; //char_rgb, remember to change back
            end else begin
                rgb = others_rgb;
            end
        end
    end

    always @(*) begin
        if(~video_on) begin
            others_rgb = BLACK;
        end else if(obstacle_on_for_all) begin
            others_rgb = obstacle_rgb;
        end else if(map_on) begin
            others_rgb = map_rgb;
        end else begin
            others_rgb = background_rgb;
        end
    end


    //-----------------------------bcd Sequence--------------------------------
    bcd_seq_display_controller #(
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .SEQ_LEN(BCD_SEQ_LEN),
        .SEQ_DIGITS(BCD_SEQ_DIGITS),
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .FONT_WIDTH(FONT_WIDTH)
    ) sequence_inst(
        .seq_on(bcd_seq_on_for_all),
        .seq(bcd_seq[bcd_seq_on_id*BCD_SEQ_LEN +: BCD_SEQ_LEN]),
        .seq_x_rom(bcd_seq_x_rom),
        .seq_y_rom(bcd_seq_y_rom[bcd_seq_on_id]),
        .background_rgb(others_rgb),
        .rgb(bcd_seq_rgb)
    );
    //-----------------------------bcd Sequence--------------------------------

    //-----------------------------ascii Sequence--------------------------------
    wire [MAX_CHAR_NUM * CHAR_WIDTH - 1:0] ascii_seq;
    string_rom string_rom_inst(
        .addr(ascii_seq_on_id),
        .string_out(ascii_seq)
    );

    ascii_seq_display_controller #(
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .MAX_CHAR_NUM(MAX_CHAR_NUM),
        .CHAR_WIDTH(CHAR_WIDTH),
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .FONT_WIDTH(FONT_WIDTH)
    ) ascii_sequence_inst(
        .seq_on(ascii_seq_on_for_all),
        .seq(ascii_seq),
        .seq_x_rom(ascii_seq_x_rom),
        .seq_y_rom(ascii_seq_y_rom[ascii_seq_on_id]),
        .background_rgb(others_rgb),
        .rgb(ascii_seq_rgb)
    );
    //-----------------------------ascii Sequence--------------------------------

    //------------------------------Map--------------------------------
    Map #(
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .PHY_WIDTH(PHY_WIDTH),
        .WALL_WIDTH(WALL_WIDTH),
        .WALL_HEIGHT(WALL_HEIGHT),
        .MAP_Y_OFFSET(MAP_Y_OFFSET),
        .MAP_X_OFFSET(MAP_X_OFFSET),
        .MAP_WIDTH_X(MAP_WIDTH_X),
        .CAMERA_WIDTH(CAMERA_WIDTH)
    ) map_inst(
        .camera_y(camera_y),
        .camera_offset(camera_offset),
        .map_x(map_x),
        .map_y(map_y),
        .map_on(map_on),
        .background_rgb(background_rgb),
        .rgb(map_rgb)
    );
    //-----------------------------------------------------------------
    
    character_display_controller #(
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .SCREEN_WIDTH(SCREEN_WIDTH),
        .CHAR_WIDTH_X(CHAR_WIDTH_X),
        .CHAR_WIDTH_Y(CHAR_WIDTH_Y)
    ) char_inst(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .char_x_rom(char_x_rom[SCREEN_WIDTH - 1:0]),
        .char_y_rom(char_y_rom[SCREEN_WIDTH - 1:0]),
        .char_on(char_on),
        .char_face(char_face),
        .char_id(char_display_id),
        .background_rgb(others_rgb),
        .rgb(char_rgb)
    );
    
    //-----------------------------------------------------------------

    //------------------------------Obstacle-------------------------------- // TODO: write module for obstacle print
    obstacle_display_controller #(
        .OBSTACLE_WIDTH(OBSTACLE_WIDTH),
        .BLOCK_LEN_WIDTH(BLOCK_LEN_WIDTH),
        .PHY_WIDTH(PHY_WIDTH),
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .SCREEN_WIDTH(SCREEN_WIDTH)
    ) obstacle_inst(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .obstacle_x_rom(obstacle_x_rom[obstacle_on_id]),
        .obstacle_y_rom(obstacle_y_rom[obstacle_on_id]),
        .obstacle_block_abs_y(obstacle_abs_pos_y[obstacle_on_id*PHY_WIDTH +: PHY_WIDTH]),
        .obstacle_abs_pos_y(obstacle_abs_pos_y[obstacle_on_id*PHY_WIDTH +: PHY_WIDTH]),
        .obstacle_abs_pos_x(obstacle_abs_pos_x[obstacle_on_id*PHY_WIDTH +: PHY_WIDTH]),
        .obstacle_on(obstacle_on_for_all),
        .rgb(obstacle_rgb)
    );
    //-----------------------------------------------------------------

    //------------------------------Background--------------------------------
    obstacle_display_controller #(
        .OBSTACLE_WIDTH(OBSTACLE_WIDTH),
        .BLOCK_LEN_WIDTH(BLOCK_LEN_WIDTH),
        .PHY_WIDTH(PHY_WIDTH),
        .PIXEL_WIDTH(PIXEL_WIDTH),
        .SCREEN_WIDTH(SCREEN_WIDTH)
    ) background_inst(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .obstacle_x_rom(background_x_rom),
        .obstacle_y_rom(background_y_rom),
        .obstacle_block_abs_y(background_block_abs_y),
        .obstacle_abs_pos_y(background_abs_pos_y),
        .obstacle_abs_pos_x(background_abs_pos_x),
        .obstacle_on(background_on),
        .rgb(background_rgb)
    );
    //-----------------------------------------------------------------

endmodule
