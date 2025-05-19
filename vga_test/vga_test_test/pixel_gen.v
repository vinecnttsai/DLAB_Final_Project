`timescale 1ns / 1ps
// camera_y is the y coordinate of the camera, is TODO
// obstacle_print_module
module pixel_gen #(
    //-----------Sequence debug parameters-----------
    parameter SEQ_DIGITS = 4,
    parameter SEQ_NUM = 1,
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
    parameter CHAR_WIDTH_X = 42, // width of character
    parameter CHAR_WIDTH_Y = 52, // height of character
    //-----------Obstacle parameters-----------
    parameter OBSTACLE_NUM = 7,
    parameter OBSTACLE_WIDTH = 10,
    parameter OBSTACLE_HEIGHT = 20,
    parameter BLOCK_LEN_WIDTH = 4, // max 15
    //-----------Screen parameters-----------
    parameter SCREEN_WIDTH = 10,
    //-----------Physical parameters-----------
    parameter PHY_WIDTH = 14
    )(
    // remember to delete
    input sw,
    //--------------------------------
    //--------------------------------
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
    wire [PIXEL_WIDTH - 1:0] char_rgb;
    wire [PIXEL_WIDTH - 1:0] map_rgb;
    wire [PIXEL_WIDTH - 1:0] obstacle_rgb;
    //----------------------------------------------------------------------------
    
    //------------------------------Pixel Location Status Signals------------------------------
    wire [SEQ_NUM - 1:0] debug_seq_on;
    wire map_on;
    wire char_on;
    wire [OBSTACLE_NUM - 1:0] obstacle_on;
    wire obstacle_on_for_all;
    reg [$clog2(OBSTACLE_NUM + 1) - 1:0] obstacle_on_id;
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

    //-----------------------------Map Relative Position Signals-----------------------------
    wire [PHY_WIDTH-1:0] map_y;
    wire [PHY_WIDTH-1:0] map_x;
    assign map_y = y + camera_offset - MAP_Y_OFFSET;
    assign map_x = x - MAP_X_OFFSET;
    //----------------------------------------------------------------------------------------

    //-----------------------------Character Relative Position Signals-----------------------------
    wire [PHY_WIDTH - 1:0] char_y_rom;
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
            assign obstacle_on[m] = ((x >= obstacle_abs_pos_x[m*PHY_WIDTH +: PHY_WIDTH]) && (x < obstacle_abs_pos_x[m*PHY_WIDTH +: PHY_WIDTH] + obstacle_block_width[m*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] * OBSTACLE_WIDTH) && (y >= obstacle_abs_pos_y[m*PHY_WIDTH +: PHY_WIDTH]) && (y < obstacle_abs_pos_y[m*PHY_WIDTH +: PHY_WIDTH] + OBSTACLE_HEIGHT));
        end
    endgenerate
    assign obstacle_on_for_all = |obstacle_on;

    always @(*) begin
        case(obstacle_on)
            7'b0000001: obstacle_on_id = 3'b000;
            7'b0000010: obstacle_on_id = 3'b001;
            7'b0000100: obstacle_on_id = 3'b010;
            7'b0001000: obstacle_on_id = 3'b011;
            7'b0010000: obstacle_on_id = 3'b100;
            7'b0100000: obstacle_on_id = 3'b101;
            7'b1000000: obstacle_on_id = 3'b110;
            default: obstacle_on_id = 3'b000;
        endcase
    end
    //----------------------------------------------------------------------------------------
    
    // Set RGB output value based on status signals
    always @(*) begin 
        if(~video_on) begin
            rgb = BLACK;
        end else begin

            if(debug_seq_on[0]) begin
                rgb = debug_seq[0 * UNIT_SEQ_WIDTH + (debug_seq_y[0] * SEQ_DIGITS * FONT_WIDTH + x) * PIXEL_WIDTH +: PIXEL_WIDTH];
            end else if(char_on) begin
                rgb = char_rgb; //char_rgb, remember to change back
            end else if(obstacle_on_for_all) begin // not all blank
                rgb = obstacle_rgb;
            end else if(map_on) begin
                rgb = map_rgb;
            end else begin
                rgb = YELLOW;
            end
        end
    end

    //------------------------------Map--------------------------------
    Map #(
        .PHY_WIDTH(PHY_WIDTH),
        .MAP_WIDTH_X(MAP_WIDTH_X)
        //.MAP_WIDTH_Y(MAP_WIDTH_Y)
    ) map_inst(
        .map_x(map_x),
        .map_y(map_y),
        .map_on(map_on),
        .rgb(map_rgb)
    );
    //-----------------------------------------------------------------

    //------------------------------tb for chatacter display controller--------------------------------
    reg [2:0] cnt;
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            cnt <= 0;
        end else if (tb_clk) begin
            cnt <= cnt == 3'b101 ? 3'b000 : cnt + 1;
        end
    end
    
    fq_div #( .N(200000000) ) fq_div_inst(
        .org_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .div_n_clk(tb_clk)
    );

    //------------------------------Character--------------------------------
    wire [1:0] face;
    assign face = sw ? 2'b10 : 2'b01;
    
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
        .char_face(face),
        .char_id(cnt),
        .rgb(char_rgb)
    );
    
    //-----------------------------------------------------------------

    //------------------------------Obstacle-------------------------------- // TODO: write module for obstacle print
    obstacle_display_controller #(
        .OBSTACLE_NUM(OBSTACLE_NUM),
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
        .obstacle_abs_pos_y(obstacle_abs_pos_y[obstacle_on_id*PHY_WIDTH +: PHY_WIDTH]),
        .obstacle_abs_pos_x(obstacle_abs_pos_x[obstacle_on_id*PHY_WIDTH +: PHY_WIDTH]),
        .obstacle_on(obstacle_on_for_all),
        .obstacle_on_id(obstacle_on_id),
        .rgb(obstacle_rgb)
    );
    //-----------------------------------------------------------------

endmodule
