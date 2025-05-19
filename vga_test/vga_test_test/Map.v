module Map #(
    parameter PIXEL_WIDTH = 12,
    parameter PHY_WIDTH = 14
) (
    input [4:0] camera_y,
    input [PHY_WIDTH-1:0] map_x,
    input [PHY_WIDTH-1:0] map_y,
    input map_on,
    output reg [PIXEL_WIDTH-1:0] rgb
);
// 80 * 80 for digit, 470 * 460 for map size
localparam MAP_COLOR = 12'hA21;
localparam DIGIT_COLOR = 12'hFFF; // white
localparam FIRST_DIGIT_X = 130; // 240 - 220 = 20
localparam SECOND_DIGIT_X = 250; // 240 + 100
localparam DIGIT_Y = 160;
localparam DIGIT_WIDTH = 80;

wire [7:0] digits;
bin_to_bcd_converter #(
    .DIGITS(2)
) bin_to_bcd_converter_inst(
    .in({3'b000, camera_y}),
    .out(digits)
);

reg [3:0] row;
wire [9:0] first_digit_bitmap_row;
wire [9:0] second_digit_bitmap_row;

wire first_digit_on;
wire second_digit_on;
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
        case ({second_digit_on, first_digit_on})
            2'b01: rgb = (first_digit_bitmap_row[map_first_digit_x_safe]) ? DIGIT_COLOR : MAP_COLOR;
            2'b10: rgb = (second_digit_bitmap_row[map_second_digit_x_safe]) ? DIGIT_COLOR : MAP_COLOR;
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
            4'd9: bitmap_row = 10'b0001111000;
            4'd8: bitmap_row = 10'b0010000100;
            4'd7: bitmap_row = 10'b0100000010;
            4'd6: bitmap_row = 10'b0100001010;
            4'd5: bitmap_row = 10'b0100010010;
            4'd4: bitmap_row = 10'b0100100010;
            4'd3: bitmap_row = 10'b0101000010;
            4'd2: bitmap_row = 10'b0010000100;
            4'd1: bitmap_row = 10'b0001111000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd1: case (row)
            4'd9: bitmap_row = 10'b0000100000;
            4'd8: bitmap_row = 10'b0001100000;
            4'd7: bitmap_row = 10'b0010100000;
            4'd6: bitmap_row = 10'b0000100000;
            4'd5: bitmap_row = 10'b0000100000;
            4'd4: bitmap_row = 10'b0000100000;
            4'd3: bitmap_row = 10'b0000100000;
            4'd2: bitmap_row = 10'b0000100000;
            4'd1: bitmap_row = 10'b0011111110;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd2: case (row)
            4'd9: bitmap_row = 10'b0001111000;
            4'd8: bitmap_row = 10'b0010000100;
            4'd7: bitmap_row = 10'b0000000100;
            4'd6: bitmap_row = 10'b0000001000;
            4'd5: bitmap_row = 10'b0000010000;
            4'd4: bitmap_row = 10'b0000100000;
            4'd3: bitmap_row = 10'b0001000000;
            4'd2: bitmap_row = 10'b0010000000;
            4'd1: bitmap_row = 10'b0011111110;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd3: case (row)
            4'd9: bitmap_row = 10'b0001111000;
            4'd8: bitmap_row = 10'b0010000100;
            4'd7: bitmap_row = 10'b0000000100;
            4'd6: bitmap_row = 10'b0001111000;
            4'd5: bitmap_row = 10'b0000000100;
            4'd4: bitmap_row = 10'b0000000100;
            4'd3: bitmap_row = 10'b0010000100;
            4'd2: bitmap_row = 10'b0001111000;
            4'd1: bitmap_row = 10'b0000000000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd4: case (row)
            4'd9: bitmap_row = 10'b0000010000;
            4'd8: bitmap_row = 10'b0000110000;
            4'd7: bitmap_row = 10'b0001010000;
            4'd6: bitmap_row = 10'b0010010000;
            4'd5: bitmap_row = 10'b0100010000;
            4'd4: bitmap_row = 10'b0111111110;
            4'd3: bitmap_row = 10'b0000010000;
            4'd2: bitmap_row = 10'b0000010000;
            4'd1: bitmap_row = 10'b0000010000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd5: case (row)
            4'd9: bitmap_row = 10'b0011111110;
            4'd8: bitmap_row = 10'b0010000000;
            4'd7: bitmap_row = 10'b0010000000;
            4'd6: bitmap_row = 10'b0011111000;
            4'd5: bitmap_row = 10'b0000000100;
            4'd4: bitmap_row = 10'b0000000100;
            4'd3: bitmap_row = 10'b0010000100;
            4'd2: bitmap_row = 10'b0001111000;
            4'd1: bitmap_row = 10'b0000000000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd6: case (row)
            4'd9: bitmap_row = 10'b0001111000;
            4'd8: bitmap_row = 10'b0010000000;
            4'd7: bitmap_row = 10'b0010000000;
            4'd6: bitmap_row = 10'b0011111000;
            4'd5: bitmap_row = 10'b0010000100;
            4'd4: bitmap_row = 10'b0010000100;
            4'd3: bitmap_row = 10'b0010000100;
            4'd2: bitmap_row = 10'b0001111000;
            4'd1: bitmap_row = 10'b0000000000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd7: case (row)
            4'd9: bitmap_row = 10'b0011111110;
            4'd8: bitmap_row = 10'b0000000100;
            4'd7: bitmap_row = 10'b0000001000;
            4'd6: bitmap_row = 10'b0000010000;
            4'd5: bitmap_row = 10'b0000100000;
            4'd4: bitmap_row = 10'b0000100000;
            4'd3: bitmap_row = 10'b0000100000;
            4'd2: bitmap_row = 10'b0000100000;
            4'd1: bitmap_row = 10'b0000000000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd8: case (row)
            4'd9: bitmap_row = 10'b0001111000;
            4'd8: bitmap_row = 10'b0010000100;
            4'd7: bitmap_row = 10'b0010000100;
            4'd6: bitmap_row = 10'b0001111000;
            4'd5: bitmap_row = 10'b0010000100;
            4'd4: bitmap_row = 10'b0010000100;
            4'd3: bitmap_row = 10'b0010000100;
            4'd2: bitmap_row = 10'b0001111000;
            4'd1: bitmap_row = 10'b0000000000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd9: case (row)
            4'd9: bitmap_row = 10'b0001111000;
            4'd8: bitmap_row = 10'b0010000100;
            4'd7: bitmap_row = 10'b0010000100;
            4'd6: bitmap_row = 10'b0001111100;
            4'd5: bitmap_row = 10'b0000000100;
            4'd4: bitmap_row = 10'b0000000100;
            4'd3: bitmap_row = 10'b0010000100;
            4'd2: bitmap_row = 10'b0001111000;
            4'd1: bitmap_row = 10'b0000000000;
            4'd0: bitmap_row = 10'b0000000000;
            default: bitmap_row = 10'b0000000000;
        endcase
        4'd10: case (row) // minus sign
            4'd9: bitmap_row = 10'b0000000000;
            4'd8: bitmap_row = 10'b0000000000;
            4'd7: bitmap_row = 10'b0000000000;
            4'd6: bitmap_row = 10'b0000000000;
            4'd5: bitmap_row = 10'b0011111110;
            4'd4: bitmap_row = 10'b0000000000;
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
