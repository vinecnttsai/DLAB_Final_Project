// Auto-generated Verilog pixel data (12-bit RGB)
module IDLE_2_CHAR #(
    parameter COLOR_WIDTH = 4,
    parameter SCREEN_WIDTH = 10
) (
    input sys_clk,
    input sys_rst_n,
    input [SCREEN_WIDTH - 1:0] char_x_rom,
    input [SCREEN_WIDTH - 1:0] char_y_rom,
    input char_on,
    output reg [COLOR_WIDTH - 1:0] rgb_id
);

// 0 for 12'hACF;
// 1 for 12'h7AF;
// 2 for 12'h000;
// 3 for 12'h00F;
// 4 for 12'h008;
// 5 for 12'hF90;
// 6 for 12'hA50;
// 7 for 12'h420;
// 8 for 12'h0CF;
// 9 for 12'h13A;
// 10 for 12'h027;
// 11 for 12'hFFF;

localparam CHAR_WIDTH_X = 21;
localparam CHAR_WIDTH_Y = 25;
(* rom_style = "block" *) reg [CHAR_WIDTH_X * CHAR_WIDTH_Y * COLOR_WIDTH - 1:0] pixel_map = {
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h2,     4'h2,     4'h2,     4'h2,     4'h2,     4'h2,     4'h2,     4'h2,     4'h2,     4'hB,     4'hB,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'hA,     4'h9,     4'h9,     4'h9,     4'h9,     4'h9,     4'h9,     4'h9,     4'h9,     4'h9,     4'h2,     4'hB,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'hA,     4'hA,     4'hA,     4'hA,     4'h9,     4'h9,     4'h9,     4'h9,     4'h9,     4'h9,     4'h9,     4'h2,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'hA,     4'hA,     4'hA,     4'h2,     4'h2,     4'hA,     4'hA,     4'h9,     4'h9,     4'h9,     4'h9,     4'h9,     4'hA,     4'h2,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'hA,     4'hA,     4'h2,     4'h1,     4'h1,     4'h2,     4'h2,     4'hA,     4'hA,     4'h9,     4'h9,     4'h9,     4'hA,     4'h2,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'hA,     4'h2,     4'h0,     4'h0,     4'h0,     4'h0,     4'h2,     4'h2,     4'h2,     4'h2,     4'hA,     4'h2,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h2,     4'h0,     4'h0,     4'h2,     4'h0,     4'h0,     4'h2,     4'h1,     4'h2,     4'h2,     4'hB,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h1,     4'h0,     4'h0,     4'h2,     4'h0,     4'h0,     4'h2,     4'h0,     4'h2,     4'hB,     4'hB,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h0,     4'h0,     4'h0,     4'h0,     4'h0,     4'h0,     4'h0,     4'h2,     4'hB,     4'hB,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h2,     4'h2,     4'h2,     4'h1,     4'h0,     4'h0,     4'h0,     4'h0,     4'h2,     4'h2,     4'h2,     4'h2,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h3,     4'h3,     4'h3,     4'h4,     4'h2,     4'h2,     4'h2,     4'h2,     4'h2,     4'h4,     4'h3,     4'h3,     4'h3,     4'h2,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h2,     4'h2,     4'h2,     4'h2,     4'h6,     4'h6,     4'h6,     4'h6,     4'h2,     4'h2,     4'h4,     4'h4,     4'h4,     4'h4,     4'h2, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h4,     4'h4,     4'h7,     4'h6,     4'h5,     4'h5,     4'h5,     4'h5,     4'h5,     4'h6,     4'h2,     4'h3,     4'h3,     4'h3,     4'h2, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h4,     4'h3,     4'h2,     4'h6,     4'h5,     4'h5,     4'h5,     4'h5,     4'h5,     4'h5,     4'h5,     4'h7,     4'h2,     4'h3,     4'h3,     4'h2, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h4,     4'h3,     4'h2,     4'h6,     4'h5,     4'h5,     4'h5,     4'h5,     4'h5,     4'h5,     4'h5,     4'h7,     4'h6,     4'h2,     4'h3,     4'h2, 
    4'hB,     4'hB,     4'hB,     4'h2,     4'h4,     4'h3,     4'h6,     4'h2,     4'h7,     4'h6,     4'h5,     4'h5,     4'h5,     4'h5,     4'h5,     4'h6,     4'h7,     4'h6,     4'h2,     4'h3,     4'h2, 
    4'hB,     4'hB,     4'h2,     4'h4,     4'h3,     4'h3,     4'h7,     4'h2,     4'h7,     4'h7,     4'h7,     4'h7,     4'h8,     4'h8,     4'h7,     4'h7,     4'h2,     4'h7,     4'h2,     4'h3,     4'h2, 
    4'hB,     4'h2,     4'h4,     4'h3,     4'h3,     4'h3,     4'h0,     4'h2,     4'h7,     4'h6,     4'h6,     4'h2,     4'h2,     4'h7,     4'h6,     4'h6,     4'h2,     4'h0,     4'h2,     4'h3,     4'h2, 
    4'hB,     4'hB,     4'h2,     4'h4,     4'h3,     4'h3,     4'h3,     4'h2,     4'h7,     4'h6,     4'h6,     4'h2,     4'hB,     4'h7,     4'h6,     4'h6,     4'h2,     4'h2,     4'h4,     4'h3,     4'h2, 
    4'hB,     4'hB,     4'hB,     4'h2,     4'h2,     4'h3,     4'h3,     4'h2,     4'hA,     4'h9,     4'h9,     4'h2,     4'hB,     4'hA,     4'h9,     4'h9,     4'h2,     4'h4,     4'h3,     4'h2,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h2,     4'h2,     4'hA,     4'h9,     4'h9,     4'h2,     4'hB,     4'hA,     4'h9,     4'h9,     4'h2,     4'h4,     4'h2,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'hA,     4'hA,     4'hA,     4'h2,     4'hB,     4'hA,     4'hA,     4'hA,     4'hA,     4'h2,     4'hB,     4'hB,     4'hB, 
    4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'hB,     4'h2,     4'h2,     4'h2,     4'h2,     4'h2,     4'hB,     4'h2,     4'h2,     4'h2,     4'h2,     4'hB,     4'hB,     4'hB,     4'hB

};

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        rgb_id <= 4'hB;
    end else if (char_on) begin
        rgb_id <= pixel_map[(char_y_rom * CHAR_WIDTH_X + char_x_rom) * COLOR_WIDTH +: COLOR_WIDTH];
    end else begin
        rgb_id <= 4'hB;
    end
end
endmodule
