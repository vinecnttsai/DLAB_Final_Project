module Map #(
    parameter PIXEL_WIDTH = 12,
    parameter PHY_WIDTH = 16,
    parameter WALL_WIDTH = 10,
    parameter WALL_HEIGHT = 20,
    parameter MAP_Y_OFFSET = 0,
    parameter MAP_X_OFFSET = 140,
    parameter MAP_WIDTH_X = 480,
    parameter CAMERA_WIDTH = 6
) (
    input [CAMERA_WIDTH - 1:0] camera_y,
    input [CAMERA_WIDTH - 1:0] camera_offset,
    input [PHY_WIDTH-1:0] map_x,
    input [PHY_WIDTH-1:0] map_y,
    input map_on,
    input [PIXEL_WIDTH-1:0] background_rgb,
    output reg [PIXEL_WIDTH-1:0] rgb
);
// 80 * 80 for digit, 460 * 470 for map size
localparam MAP_COLOR = 12'hFD8;
localparam DIGIT_COLOR = 12'h5FF; // Yellow
localparam FIRST_DIGIT_X = 140; // 240 - 220 = 20
localparam SECOND_DIGIT_X = 260; // 240 + 100
localparam DIGIT_Y = 160;
localparam DIGIT_WIDTH = 80;

wire [7:0] digits;
bin_to_bcd_converter #(
    .DIGITS(2)
) bin_to_bcd_converter_inst(
    .in({{8 - CAMERA_WIDTH{1'b0}}, camera_y + 1}),
    .out(digits)
);

reg [3:0] row;
wire [9:0] first_digit_bitmap_row;
wire [9:0] second_digit_bitmap_row;

wire wall_on;
wire first_digit_on;
wire second_digit_on;
assign wall_on = map_x < WALL_WIDTH || map_x >= MAP_WIDTH_X - WALL_WIDTH || map_y + camera_offset < WALL_HEIGHT;
assign first_digit_on = map_x >= FIRST_DIGIT_X && map_x < FIRST_DIGIT_X + DIGIT_WIDTH && map_y >= DIGIT_Y && map_y < DIGIT_Y + DIGIT_WIDTH;
assign second_digit_on = map_x >= SECOND_DIGIT_X && map_x < SECOND_DIGIT_X + DIGIT_WIDTH && map_y >= DIGIT_Y && map_y < DIGIT_Y + DIGIT_WIDTH;

reg [PHY_WIDTH-1:0] map_first_digit_x_safe;
reg [PHY_WIDTH-1:0] map_second_digit_x_safe;
reg [PHY_WIDTH-1:0] map_y_safe;

always @(*) begin
    map_first_digit_x_safe = (map_x - FIRST_DIGIT_X) >>> 3;
    map_second_digit_x_safe = (map_x - SECOND_DIGIT_X) >>> 3;
    map_y_safe = (map_y - DIGIT_Y) >>> 3;
end

digit_font_rom_10 digit_font_rom_10_inst(
    .digit(digits[3:0]),
    .row(row),
    .bitmap_row(first_digit_bitmap_row)
);

digit_font_rom_10 digit_font_rom_10_inst_2(
    .digit(digits[7:4]),
    .row(row),
    .bitmap_row(second_digit_bitmap_row)
);

always @(*) begin
    row = (second_digit_on || first_digit_on) ? map_y_safe[3:0] : 4'd0;
end

always @(*) begin
    if (map_on) begin
        case ({wall_on, second_digit_on, first_digit_on})
            3'b001: rgb = (first_digit_bitmap_row[map_first_digit_x_safe]) ? DIGIT_COLOR : MAP_COLOR;
            3'b010: rgb = (second_digit_bitmap_row[map_second_digit_x_safe]) ? DIGIT_COLOR : MAP_COLOR;
            3'b100: rgb = background_rgb;
            default: rgb = MAP_COLOR;
        endcase
    end
    else begin
        rgb = 12'hFFF;
    end
end

endmodule
module digit_font_rom_10 (
    input [3:0] digit,       // 0~9, 10 for minus
    input [3:0] row,         // 0~9
    output reg [9:0] bitmap_row // 該行的10bit bitmap
);

(* rom_style = "block" *)

always @(*) begin
    case (digit)
        4'd0: case (row)
            4'd9: bitmap_row = 10'b0011111100;
            4'd8: bitmap_row = 10'b0110000110;
            4'd7: bitmap_row = 10'b1100000011;
            4'd6: bitmap_row = 10'b1100000011;
            4'd5: bitmap_row = 10'b1100000011;
            4'd4: bitmap_row = 10'b1100000011;
            4'd3: bitmap_row = 10'b1100000011;
            4'd2: bitmap_row = 10'b0110000110;
            4'd1: bitmap_row = 10'b0011111100;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd1: case (row)
            4'd9: bitmap_row = 10'b0001100000;
            4'd8: bitmap_row = 10'b0011100000;
            4'd7: bitmap_row = 10'b0111100000;
            4'd6: bitmap_row = 10'b0001100000;
            4'd5: bitmap_row = 10'b0001100000;
            4'd4: bitmap_row = 10'b0001100000;
            4'd3: bitmap_row = 10'b0001100000;
            4'd2: bitmap_row = 10'b0001100000;
            4'd1: bitmap_row = 10'b0111111110;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd2: case (row)
            4'd9: bitmap_row = 10'b0011111100;
            4'd8: bitmap_row = 10'b0110000110;
            4'd7: bitmap_row = 10'b1100000011;
            4'd6: bitmap_row = 10'b0000000110;
            4'd5: bitmap_row = 10'b0000001100;
            4'd4: bitmap_row = 10'b0000110000;
            4'd3: bitmap_row = 10'b0011000000;
            4'd2: bitmap_row = 10'b0110000000;
            4'd1: bitmap_row = 10'b1111111111;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd3: case (row)
            4'd9: bitmap_row = 10'b0011111100;
            4'd8: bitmap_row = 10'b0110000110;
            4'd7: bitmap_row = 10'b0000000110;
            4'd6: bitmap_row = 10'b0000001100;
            4'd5: bitmap_row = 10'b0001111000;
            4'd4: bitmap_row = 10'b0000001100;
            4'd3: bitmap_row = 10'b0000000110;
            4'd2: bitmap_row = 10'b0110000110;
            4'd1: bitmap_row = 10'b0011111100;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd4: case (row)
            4'd9: bitmap_row = 10'b0000011000;
            4'd8: bitmap_row = 10'b0000111000;
            4'd7: bitmap_row = 10'b0001111000;
            4'd6: bitmap_row = 10'b0011011000;
            4'd5: bitmap_row = 10'b0110011000;
            4'd4: bitmap_row = 10'b1100011000;
            4'd3: bitmap_row = 10'b1111111111;
            4'd2: bitmap_row = 10'b0000011000;
            4'd1: bitmap_row = 10'b0000011000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd5: case (row)
            4'd9: bitmap_row = 10'b1111111111;
            4'd8: bitmap_row = 10'b1100000000;
            4'd7: bitmap_row = 10'b1100000000;
            4'd6: bitmap_row = 10'b1111111100;
            4'd5: bitmap_row = 10'b0000000110;
            4'd4: bitmap_row = 10'b0000000011;
            4'd3: bitmap_row = 10'b1100000011;
            4'd2: bitmap_row = 10'b0110000110;
            4'd1: bitmap_row = 10'b0011111100;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd6: case (row)
            4'd9: bitmap_row = 10'b0011111100;
            4'd8: bitmap_row = 10'b0110000110;
            4'd7: bitmap_row = 10'b1100000000;
            4'd6: bitmap_row = 10'b1100000000;
            4'd5: bitmap_row = 10'b1111111100;
            4'd4: bitmap_row = 10'b1100000110;
            4'd3: bitmap_row = 10'b1100000011;
            4'd2: bitmap_row = 10'b0110000110;
            4'd1: bitmap_row = 10'b0011111100;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd7: case (row)
            4'd9: bitmap_row = 10'b1111111111;
            4'd8: bitmap_row = 10'b0000000011;
            4'd7: bitmap_row = 10'b0000000110;
            4'd6: bitmap_row = 10'b0000001100;
            4'd5: bitmap_row = 10'b0000011000;
            4'd4: bitmap_row = 10'b0000110000;
            4'd3: bitmap_row = 10'b0001100000;
            4'd2: bitmap_row = 10'b0011000000;
            4'd1: bitmap_row = 10'b0110000000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd8: case (row)
            4'd9: bitmap_row = 10'b0011111100;
            4'd8: bitmap_row = 10'b0110000110;
            4'd7: bitmap_row = 10'b1100000011;
            4'd6: bitmap_row = 10'b0110000110;
            4'd5: bitmap_row = 10'b0011111100;
            4'd4: bitmap_row = 10'b0110000110;
            4'd3: bitmap_row = 10'b1100000011;
            4'd2: bitmap_row = 10'b0110000110;
            4'd1: bitmap_row = 10'b0011111100;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd9: case (row)
            4'd9: bitmap_row = 10'b0011111100;
            4'd8: bitmap_row = 10'b0110000110;
            4'd7: bitmap_row = 10'b1100000011;
            4'd6: bitmap_row = 10'b0110000011;
            4'd5: bitmap_row = 10'b0011111111;
            4'd4: bitmap_row = 10'b0000000011;
            4'd3: bitmap_row = 10'b0000000011;
            4'd2: bitmap_row = 10'b0110000110;
            4'd1: bitmap_row = 10'b0011111100;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd10: case (row) // minus sign
            4'd9: bitmap_row = 10'b0000000000;
            4'd8: bitmap_row = 10'b0000000000;
            4'd7: bitmap_row = 10'b0000000000;
            4'd6: bitmap_row = 10'b0000000000;
            4'd5: bitmap_row = 10'b0111111110;
            4'd4: bitmap_row = 10'b0111111110;
            4'd3: bitmap_row = 10'b0000000000;
            4'd2: bitmap_row = 10'b0000000000;
            4'd1: bitmap_row = 10'b0000000000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        default: bitmap_row = 10'b0000000000;
    endcase
end

endmodule

module bin_to_bcd_converter #(
    parameter DIGITS = 4
)(
    input  [(DIGITS * 4) - 1:0] in,
    output reg  [(DIGITS * 4) - 1:0] out
);

    localparam N = DIGITS  *  4;
    integer i, j;
    reg [N + DIGITS * 4 - 1:0] shift_reg;

    always @( * ) begin
        shift_reg = 0;
        shift_reg[N - 1:0] = in;

        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < DIGITS; j = j + 1) begin
                if (shift_reg[N + j * 4 +: 4] >= 5)
                    shift_reg[N + j * 4 +: 4] = shift_reg[N + j * 4 +: 4] + 3;
            end
            shift_reg = shift_reg << 1;
        end

        for (j = 0; j < DIGITS; j = j + 1) begin
            out[j * 4 +: 4] = shift_reg[N + j * 4 +: 4];
        end
    end
endmodule
