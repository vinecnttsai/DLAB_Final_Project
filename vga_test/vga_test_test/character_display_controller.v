// TODO: debounce char_id
module character_display_controller #(
    parameter PIXEL_WIDTH = 12,
    parameter SCREEN_WIDTH = 10,
    parameter CHAR_WIDTH_X = 42,
    parameter CHAR_WIDTH_Y = 52,
    parameter COLOR_NUM = 12
)(
    input sys_clk,
    input sys_rst_n,
    input signed [1:0] char_face,
    input [SCREEN_WIDTH - 1:0] char_x_rom,
    input [SCREEN_WIDTH - 1:0] char_y_rom,
    input char_on,
    input [2:0] char_id,
    input background_on,
    input [PIXEL_WIDTH - 1:0] background_rgb,
    output reg [PIXEL_WIDTH - 1:0] rgb
);

localparam [2:0] CHAR_DIS_NUM = 6;
localparam [2:0] COLOR_WIDTH = 4; // max 16 colors
localparam [2:0] IDLE_DIS_1 = 0, IDLE_DIS_2 = 1, CHARGE_DIS = 2, JUMP_UP_DIS = 3, JUMP_DOWN_DIS = 4, FALL_TO_GROUND_DIS = 5;

wire [COLOR_WIDTH - 1:0] color_table [CHAR_DIS_NUM - 1:0];
reg [COLOR_WIDTH - 1:0] color_id;

reg [SCREEN_WIDTH - 1:0] char_x_rom_safe, char_y_rom_safe;

reg [PIXEL_WIDTH - 1:0] background_rgb_reg;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        background_rgb_reg <= 12'hFFF;
    end
    else begin
        background_rgb_reg <= background_rgb;
    end 
end

//-------------------------------rgb_table-------------------------------------
(* rom_style = "block" *) reg [COLOR_NUM * PIXEL_WIDTH - 1:0] rgb_table = {
    12'hFFF,
    12'h027,
    12'h13A,
    12'h0CF,
    12'h420,
    12'hA50,
    12'hF90,
    12'h008,
    12'h00F,
    12'h000,
    12'h7AF,
    12'hACF
};

always @(*) begin
    case (char_id)
        IDLE_DIS_1: color_id = color_table[IDLE_DIS_1];
        IDLE_DIS_2: color_id = color_table[IDLE_DIS_2];
        CHARGE_DIS: color_id = color_table[CHARGE_DIS];
        JUMP_UP_DIS: color_id = color_table[JUMP_UP_DIS];
        JUMP_DOWN_DIS: color_id = color_table[JUMP_DOWN_DIS];
        FALL_TO_GROUND_DIS: color_id = color_table[FALL_TO_GROUND_DIS];
        default: color_id = 4'hB; // IDLE_DIS_1
    endcase
end
always @(*) begin
    rgb = (color_id == 4'hB) ? background_rgb_reg : rgb_table[color_id * PIXEL_WIDTH +: PIXEL_WIDTH]; // default color is WHITE
end
//-------------------------------rgb_table-------------------------------------


//-------------------------------module connection-------------------------------------
always @(*) begin
    char_x_rom_safe = (char_face == 2'b01) ? (char_x_rom >> 1) : ((CHAR_WIDTH_X - char_x_rom - 1) >> 1);
    char_y_rom_safe = char_y_rom >> 1;
end
IDLE_1_CHAR #(
    .COLOR_WIDTH(COLOR_WIDTH),
    .SCREEN_WIDTH(SCREEN_WIDTH)
) IDLE_1_CHAR_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .char_x_rom(char_x_rom_safe),
    .char_y_rom(char_y_rom_safe),
    .char_on(char_on),
    .rgb_id(color_table[IDLE_DIS_1])
);

IDLE_2_CHAR #(
    .COLOR_WIDTH(COLOR_WIDTH),
    .SCREEN_WIDTH(SCREEN_WIDTH)
) IDLE_2_CHAR_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .char_x_rom(char_x_rom_safe),
    .char_y_rom(char_y_rom_safe),
    .char_on(char_on),
    .rgb_id(color_table[IDLE_DIS_2])
);

CHARGE_CHAR #(
    .COLOR_WIDTH(COLOR_WIDTH),
    .SCREEN_WIDTH(SCREEN_WIDTH)
) CHARGE_CHAR_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .char_x_rom(char_x_rom_safe),
    .char_y_rom(char_y_rom_safe),
    .char_on(char_on),
    .rgb_id(color_table[CHARGE_DIS])
);

JUMP_UP_CHAR #(
    .COLOR_WIDTH(COLOR_WIDTH),
    .SCREEN_WIDTH(SCREEN_WIDTH)
) JUMP_UP_CHAR_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .char_x_rom(char_x_rom_safe),
    .char_y_rom(char_y_rom_safe),
    .char_on(char_on),
    .rgb_id(color_table[JUMP_UP_DIS])
);

JUMP_DOWN_CHAR #(
    .COLOR_WIDTH(COLOR_WIDTH),
    .SCREEN_WIDTH(SCREEN_WIDTH)
) JUMP_DOWN_CHAR_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .char_x_rom(char_x_rom_safe),
    .char_y_rom(char_y_rom_safe),
    .char_on(char_on),
    .rgb_id(color_table[JUMP_DOWN_DIS])
);

FALL_TO_GROUND_CHAR #(
    .COLOR_WIDTH(COLOR_WIDTH),
    .SCREEN_WIDTH(SCREEN_WIDTH)
) FALL_TO_GROUND_CHAR_inst (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .char_x_rom(char_x_rom_safe),
    .char_y_rom(char_y_rom_safe),
    .char_on(char_on),
    .rgb_id(color_table[FALL_TO_GROUND_DIS])
);
//-------------------------------module connection-------------------------------------

endmodule