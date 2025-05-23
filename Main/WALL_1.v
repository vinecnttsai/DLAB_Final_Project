// Auto-generated Verilog pixel data (12-bit RGB)
module WALL_1 #(
    parameter COLOR_WIDTH = 2,
    parameter SCREEN_WIDTH = 10
) (
    input sys_clk,
    input sys_rst_n,
    input [SCREEN_WIDTH - 1:0] obstacle_x_rom,
    input [SCREEN_WIDTH - 1:0] obstacle_y_rom,
    input obstacle_on,
    output reg [COLOR_WIDTH - 1:0] rgb_id
);

// 0 for 12'hAAA;
// 1 for 12'h777;
// 2 for 12'h000;
// 3 for 12'h5B0;

localparam OBSTACLE_WIDTH_X = 10;
localparam OBSTACLE_WIDTH_Y = 10;
(* rom_style = "block" *) reg [OBSTACLE_WIDTH_X * OBSTACLE_WIDTH_Y * COLOR_WIDTH - 1:0] pixel_map = {
    2'b10,     2'b10,     2'b10,     2'b01,     2'b11,     2'b10,     2'b10,     2'b10,     2'b01,     2'b10, 
    2'b00,     2'b00,     2'b00,     2'b00,     2'b00,     2'b10,     2'b00,     2'b01,     2'b00,     2'b00, 
    2'b00,     2'b00,     2'b00,     2'b00,     2'b00,     2'b10,     2'b00,     2'b00,     2'b00,     2'b00, 
    2'b00,     2'b11,     2'b00,     2'b00,     2'b10,     2'b00,     2'b00,     2'b00,     2'b11,     2'b00, 
    2'b00,     2'b10,     2'b10,     2'b01,     2'b10,     2'b11,     2'b10,     2'b00,     2'b10,     2'b10, 
    2'b10,     2'b10,     2'b00,     2'b10,     2'b01,     2'b10,     2'b10,     2'b10,     2'b01,     2'b10, 
    2'b00,     2'b10,     2'b00,     2'b00,     2'b00,     2'b00,     2'b00,     2'b01,     2'b00,     2'b00, 
    2'b00,     2'b00,     2'b10,     2'b00,     2'b00,     2'b00,     2'b10,     2'b01,     2'b00,     2'b00, 
    2'b00,     2'b00,     2'b10,     2'b11,     2'b01,     2'b00,     2'b10,     2'b00,     2'b00,     2'b00, 
    2'b10,     2'b11,     2'b01,     2'b10,     2'b00,     2'b10,     2'b01,     2'b10,     2'b11,     2'b10

};

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        rgb_id <= 2'b10; // default color : black 
    end else if (obstacle_on) begin
        rgb_id <= pixel_map[(obstacle_y_rom * OBSTACLE_WIDTH_X + obstacle_x_rom) * COLOR_WIDTH +: COLOR_WIDTH];
    end else begin
        rgb_id <= 2'b10; // default color : black 
    end
end
endmodule
