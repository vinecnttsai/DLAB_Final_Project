module Map #(
    parameter PHY_WIDTH = 14,
    parameter MAP_WIDTH_X = 480
    //parameter MAP_WIDTH_Y = 100
) (
    input [PHY_WIDTH-1:0] map_x,
    input [PHY_WIDTH-1:0] map_y,
    input map_on,
    output reg [11:0] rgb
);

localparam WALL_WIDTH = 10;
localparam WALL_HEIGHT = 20;
//localparam TOP_WALL = MAP_WIDTH_Y - WALL_WIDTH;
localparam LEFT_WALL = MAP_WIDTH_X - WALL_WIDTH;
localparam BOTTOM_WALL = 0;
localparam RIGHT_WALL = 0;

always @(*) begin
    if (map_on) begin
        if (map_x >= LEFT_WALL || map_x < RIGHT_WALL + WALL_WIDTH || map_y < BOTTOM_WALL + WALL_HEIGHT) begin //|| map_y >= MAP_WIDTH_Y) begin
            rgb = 12'h000;
        end
        else begin
            rgb = 12'hFFF;
        end
    end
    else begin
        rgb = 12'hFFF;
    end
end

endmodule
