module obstacle_display_controller #(
    parameter OBSTACLE_NUM = 10,
    parameter OBSTACLE_WIDTH = 10,
    parameter OBSTACLE_HEIGHT = 20,
    parameter BLOCK_LEN_WIDTH = 4, // max 15
    parameter SCREEN_WIDTH = 10,
    parameter PHY_WIDTH = 15,
    parameter PIXEL_WIDTH = 12,
    parameter COLOR_NUM = 4
)(
    input sys_clk,
    input sys_rst_n,
    input [SCREEN_WIDTH - 1:0] obstacle_x_rom,
    input [SCREEN_WIDTH - 1:0] obstacle_y_rom,
    input [PHY_WIDTH - 1:0] obstacle_abs_pos_x,
    input [PHY_WIDTH - 1:0] obstacle_abs_pos_y,
    input [BLOCK_LEN_WIDTH - 1:0] obstacle_block_width,
    input [COLOR_WIDTH - 1:0] obstacle_on_id,
    input obstacle_on,
    output reg [PIXEL_WIDTH - 1:0] rgb
);

localparam [1:0] OBSTACLE_DIS_NUM = 4;
localparam [1:0] COLOR_WIDTH = 2;
localparam [1:0] WALL_DIS_1 = 0, WALL_DIS_2 = 1, WALL_DIS_3 = 2, WALL_DIS_4 = 3;

wire [COLOR_WIDTH - 1:0] color_table [OBSTACLE_DIS_NUM - 1:0];
reg [COLOR_WIDTH - 1:0] color_id;

reg [SCREEN_WIDTH - 1:0] obstacle_x_rom_safe, obstacle_y_rom_safe;

(* rom_style = "block" *) reg [COLOR_NUM * PIXEL_WIDTH - 1:0] rgb_table = {
    12'h444,
    12'h222,
    12'h000,
    12'h140
};
    
always (*) begin
    obstacle_x_rom_safe = (obstacle_face == 2'b01) ? (obstacle_x_rom) % (OBSTACLE_WIDTH) : (OBSTACLE_WIDTH - obstacle_x_rom - 1) % (OBSTACLE_WIDTH);
    obstacle_y_rom_safe = (obstacle_y_rom >> 1); // cause height = width * 2, width = 10
end

obstacle_id_selector #(
    .OBSTACLE_NUM(OBSTACLE_NUM),
    .OBSTACLE_WIDTH(OBSTACLE_WIDTH),
    .OBSTACLE_HEIGHT(OBSTACLE_HEIGHT),
    .PHY_WIDTH(PHY_WIDTH),
    .COLOR_WIDTH(COLOR_WIDTH)
) obstacle_id_selector_inst(
    .obstacle_abs_pos_x(obstacle_abs_pos_x),
    .obstacle_abs_pos_y(obstacle_abs_pos_y),
    .obstacle_block_width(obstacle_block_width),
    .obstacle_on_id(obstacle_on_id),
    .color_id(color_id)
);

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
    .rgb(color_table[WALL_DIS_1])
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
    .rgb(color_table[WALL_DIS_2])
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
    .rgb(color_table[WALL_DIS_3])
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
    .rgb(color_table[WALL_DIS_4])
);  

endmodule


module obstacle_id_selector #(
    parameter OBSTACLE_NUM = 10,
    parameter OBSTACLE_WIDTH = 10,
    parameter OBSTACLE_HEIGHT = 20,
    parameter PHY_WIDTH = 15,
    parameter COLOR_WIDTH = 4, // max 16 colors
)(
    input [PHY_WIDTH - 1:0] obstacle_abs_pos_x,
    input [PHY_WIDTH - 1:0] obstacle_abs_pos_y,
    input [PHY_WIDTH - 1:0] obstacle_block_width,
    input [$clog2(OBSTACLE_NUM + 1) - 1:0] obstacle_on_id,
    output reg [COLOR_WIDTH - 1:0] color_id
);

always @(*) begin
    if (obstacle_on_id == 4'hf) begin
        color_id = 4'h0; // default wall is wall 1
    end else begin
        color_id = (obstacle_abs_y + obstacle_on_id) % OBSTACLE_NUM;
    end
end

endmodule