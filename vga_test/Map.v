module Map #(parameter MAP_WIDTH_X = 100,
            parameter MAP_WIDTH_Y = 100,
            parameter ) (
    input [9:0] map_x,
    input [9:0] map_y,
    input map_on,
    output reg [11:0] rgb
);


always @(*) begin
    if (map_on) begin
        rgb = 12'h000;
    end
    else begin
        rgb = 12'hFFF;
    end
end

endmodule
