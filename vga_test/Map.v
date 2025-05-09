module Map #(parameter MAP_WIDTH_X = 100, parameter MAP_WIDTH_Y = 100) (
    input [9:0] x,
    input [9:0] y,
    input map_on,
    output [11:0] rgb
);


(* rom_style = "block" *) reg [MAP_WIDTH_X * MAP_WIDTH_Y - 1:0] map = {
    {1000{1'b1}}, // WALL_TOP 10 * 100
    {10{1'b1}}, {80{1'b0}}, {10{1'b1}}, // WALL_MID 80 * 10
    {1000{1'b1}} // WALL_BOTTOM 10 * 100
};

assign rgb = (map_on) ? (map[y * MAP_WIDTH_X + x] ? 12'h000 : 12'hFFF) : 12'hFFF;

endmodule
