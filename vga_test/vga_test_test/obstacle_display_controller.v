module obstacle_display_controller #(
    parameter OBSTACLE_WIDTH = 10,
    parameter BLOCK_LEN_WIDTH = 4, // max 15
    parameter SCREEN_WIDTH = 10,
    parameter PHY_WIDTH = 14,
    parameter PIXEL_WIDTH = 12,
    parameter COLOR_NUM = 4
)(
    input sys_clk,
    input sys_rst_n,
    input [SCREEN_WIDTH - 1:0] obstacle_x_rom,
    input [SCREEN_WIDTH - 1:0] obstacle_y_rom,
    input [PHY_WIDTH - 1:0] obstacle_block_abs_y,
    input [PHY_WIDTH - 1:0] obstacle_abs_pos_y,
    input [PHY_WIDTH - 1:0] obstacle_abs_pos_x,
    input obstacle_on,
    output reg [PIXEL_WIDTH - 1:0] rgb
);

localparam OBSTACLE_DIS_NUM = 4;
localparam COLOR_WIDTH = 2;
localparam WALL_DIS_1 = 0, WALL_DIS_2 = 1, WALL_DIS_3 = 2, WALL_DIS_4 = 3;

wire [COLOR_WIDTH - 1:0] color_table [OBSTACLE_DIS_NUM - 1:0];
reg [COLOR_WIDTH - 1:0] color_id;
wire [1:0] obstacle_display_id;

wire [1:0] obstacle_face;
reg [SCREEN_WIDTH - 1:0] obstacle_x_rom_safe, obstacle_y_rom_safe;

(* rom_style = "block" *) reg [COLOR_NUM * PIXEL_WIDTH - 1:0] rgb_table = {
    12'h5B0,
    12'h000,
    12'h777,
    12'hAAA
};
    
always @(*) begin
    obstacle_x_rom_safe = (obstacle_face == 2'b01) ? (obstacle_x_rom) % (OBSTACLE_WIDTH) : (OBSTACLE_WIDTH - obstacle_x_rom - 1) % (OBSTACLE_WIDTH);
    obstacle_y_rom_safe = (obstacle_y_rom >> 1); // cause height = width * 2, width = 10
end

obstacle_id_selector #(
    .PHY_WIDTH(PHY_WIDTH),
    .COLOR_WIDTH(COLOR_WIDTH),
    .OBSTACLE_WIDTH(OBSTACLE_WIDTH)
) obstacle_id_selector_inst(
    .obstacle_x_rom(obstacle_x_rom),
    .obstacle_block_abs_y(obstacle_block_abs_y),
    .obstacle_abs_pos_y(obstacle_abs_pos_y),
    .obstacle_abs_pos_x(obstacle_abs_pos_x),
    .obstacle_display_id(obstacle_display_id),
    .obstacle_face(obstacle_face)
);

always @(*) begin   
    case (obstacle_display_id)
        WALL_DIS_1: color_id = color_table[WALL_DIS_1];
        WALL_DIS_2: color_id = color_table[WALL_DIS_2];
        WALL_DIS_3: color_id = color_table[WALL_DIS_3];
        WALL_DIS_4: color_id = color_table[WALL_DIS_4];
    endcase
end

always @(*) begin
    rgb = rgb_table[color_id * PIXEL_WIDTH +: PIXEL_WIDTH]; // default color is WHITE
end

WALL_1 #(
    .SCREEN_WIDTH(SCREEN_WIDTH),
    .COLOR_WIDTH(COLOR_WIDTH)
) WALL_1_inst(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .obstacle_x_rom(obstacle_x_rom_safe),
    .obstacle_y_rom(obstacle_y_rom_safe),
    .obstacle_on(obstacle_on),
    .rgb_id(color_table[WALL_DIS_1])
);

WALL_2 #(
    .SCREEN_WIDTH(SCREEN_WIDTH),
    .COLOR_WIDTH(COLOR_WIDTH)
) WALL_2_inst(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .obstacle_x_rom(obstacle_x_rom_safe),
    .obstacle_y_rom(obstacle_y_rom_safe),
    .obstacle_on(obstacle_on),
    .rgb_id(color_table[WALL_DIS_2])
);  

WALL_3 #(
    .SCREEN_WIDTH(SCREEN_WIDTH),
    .COLOR_WIDTH(COLOR_WIDTH)
) WALL_3_inst(          
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .obstacle_x_rom(obstacle_x_rom_safe),
    .obstacle_y_rom(obstacle_y_rom_safe),
    .obstacle_on(obstacle_on),
    .rgb_id(color_table[WALL_DIS_3])
);  

WALL_4 #(
    .SCREEN_WIDTH(SCREEN_WIDTH),
    .COLOR_WIDTH(COLOR_WIDTH)
) WALL_4_inst(  
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .obstacle_x_rom(obstacle_x_rom_safe),
    .obstacle_y_rom(obstacle_y_rom_safe),
    .obstacle_on(obstacle_on),
    .rgb_id(color_table[WALL_DIS_4])
);  

endmodule


module obstacle_id_selector #(
    parameter SCREEN_WIDTH = 10,
    parameter PHY_WIDTH = 15,
    parameter COLOR_WIDTH = 2, // max 4 wall style,
    parameter OBSTACLE_WIDTH = 10
)(
    input [SCREEN_WIDTH - 1:0] obstacle_x_rom,
    input [PHY_WIDTH - 1:0] obstacle_block_abs_y,
    input [PHY_WIDTH - 1:0] obstacle_abs_pos_y, // padding to 15-bit
    input [PHY_WIDTH - 1:0] obstacle_abs_pos_x,
    output reg [COLOR_WIDTH - 1:0] obstacle_display_id,
    output reg [1:0] obstacle_face
);
//-----------------------------random obstacle-------------------------------------
localparam SELECT = 2;
localparam SELECT_WIDTH = 5;
wire [PHY_WIDTH - 1:0] which_obstacle;
wire [PHY_WIDTH - 1:0] obstacle_block_x;
assign which_obstacle = obstacle_x_rom / OBSTACLE_WIDTH;
assign obstacle_block_x = (obstacle_abs_pos_x <<< 1) + obstacle_block_abs_y + OBSTACLE_WIDTH * which_obstacle - 7;
reg random_obstacle;

always @(*) begin
    random_obstacle = &obstacle_block_x[4:3] && obstacle_block_x[1:0];
end
//----------------------------------------------------------------------------------

//-------------------------------hash function-------------------------------------
localparam [2:0] HASH_TABLE_WIDTH = 3;
localparam [2:0] HASH_TABLE_NUM = 5;
wire [HASH_TABLE_WIDTH - 1:0] hash_table [HASH_TABLE_NUM - 1:0]; // 3-bit * 5 sliced = 15-bit
reg [HASH_TABLE_WIDTH - 1:0] hash;

wire [PHY_WIDTH:0] obstacle_abs_pos_y_padded = {1'b0, obstacle_abs_pos_y};

genvar i;
generate
    for (i = 0; i < HASH_TABLE_NUM; i = i + 1) begin : hash_table_gen
        assign hash_table[i] = obstacle_abs_pos_y_padded[i * HASH_TABLE_WIDTH +: HASH_TABLE_WIDTH];
    end
endgenerate
always @(*) begin
    hash = hash_table[0] ^ hash_table[1] ^ hash_table[2] ^ hash_table[3] ^ hash_table[4];
end
//----------------------------------------------------------------------------------

//---------------------------------random single obstacle-------------------------------
//---------------------------------random single obstacle-------------------------------

//-------------------------------color id selector-------------------------------------
always @(*) begin
    obstacle_display_id = random_obstacle ? obstacle_block_x[COLOR_WIDTH - 1:0] : hash[COLOR_WIDTH - 1:0]; // 0 ~ 4
end

always @(*) begin
    obstacle_face = random_obstacle | hash[1] ^ hash[0]; // 0 for right, 1 for left
end
//----------------------------------------------------------------------------------
endmodule