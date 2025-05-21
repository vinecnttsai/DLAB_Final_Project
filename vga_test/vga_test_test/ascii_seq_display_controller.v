module alphabet_font_rom_8 (
    input  [4:0] char_idx,      // 0~25 for A~Z
    input  [2:0] row,           // 0~7 row index
    output reg [7:0] bitmap_row // 8-bit bitmap for that row
);

always @(*) begin
    case (char_idx)
        5'd0: case(row) // A
            3'd7: bitmap_row = 8'b00011000;
            3'd6: bitmap_row = 8'b00100100;
            3'd5: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01000010;
            3'd3: bitmap_row = 8'b01111110;
            3'd2: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01000010;
            3'd0: bitmap_row = 8'b00000000;
        endcase
        5'd1: case(row) // B
            3'd7: bitmap_row = 8'b01111100;
            3'd6: bitmap_row = 8'b01000010;
            3'd5: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01111100;
            3'd3: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01111100;
            3'd0: bitmap_row = 8'b00000000;
        endcase
        5'd2: case(row) // C
            3'd7: bitmap_row = 8'b00111100;
            3'd6: bitmap_row = 8'b01000010;
            3'd5: bitmap_row = 8'b01000000;
            3'd4: bitmap_row = 8'b01000000;
            3'd3: bitmap_row = 8'b01000000;
            3'd2: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b00111100;
            3'd0: bitmap_row = 8'b00000000;
        endcase
        5'd3: case(row) // D
            3'd7: bitmap_row = 8'b01111100;
            3'd6: bitmap_row = 8'b01000010;
            3'd5: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01000010;
            3'd3: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01111100;
            3'd0: bitmap_row = 8'b00000000;
        endcase
        5'd4: case(row) // E
            3'd7: bitmap_row = 8'b01111110;
            3'd6: bitmap_row = 8'b01000000;
            3'd5: bitmap_row = 8'b01000000;
            3'd4: bitmap_row = 8'b01111100;
            3'd3: bitmap_row = 8'b01000000;
            3'd2: bitmap_row = 8'b01000000;
            3'd1: bitmap_row = 8'b01111110;
            3'd0: bitmap_row = 8'b00000000;
        endcase
        5'd5: case(row) // F
            3'd7: bitmap_row = 8'b01111110;
            3'd6: bitmap_row = 8'b01000000;
            3'd5: bitmap_row = 8'b01000000;
            3'd4: bitmap_row = 8'b01111100;
            3'd3: bitmap_row = 8'b01000000;
            3'd2: bitmap_row = 8'b01000000;
            3'd1: bitmap_row = 8'b01000000;
            3'd0: bitmap_row = 8'b00000000;
        endcase
        5'd6: case(row) // G
            3'd7: bitmap_row = 8'b00111100;
            3'd6: bitmap_row = 8'b01000010;
            3'd5: bitmap_row = 8'b01000000;
            3'd4: bitmap_row = 8'b01001110;
            3'd3: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b00111100;
            3'd0: bitmap_row = 8'b00000000;
        endcase
        5'd7: case(row) // H
            3'd7: bitmap_row = 8'b01000010;
            3'd6: bitmap_row = 8'b01000010;
            3'd5: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01111110;
            3'd3: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01000010;
            3'd0: bitmap_row = 8'b00000000;
        endcase
        5'd8: case(row) // I
            3'd7: bitmap_row = 8'b00111100;
            3'd6: bitmap_row = 8'b00011000;
            3'd5: bitmap_row = 8'b00011000;
            3'd4: bitmap_row = 8'b00011000;
            3'd3: bitmap_row = 8'b00011000;
            3'd2: bitmap_row = 8'b00011000;
            3'd1: bitmap_row = 8'b00111100;
            3'd0: bitmap_row = 8'b00000000;
        endcase
        5'd9: case(row) // J
            3'd7: bitmap_row = 8'b00011110;
            3'd6: bitmap_row = 8'b00000100;
            3'd5: bitmap_row = 8'b00000100;
            3'd4: bitmap_row = 8'b00000100;
            3'd3: bitmap_row = 8'b01000100;
            3'd2: bitmap_row = 8'b01000100;
            3'd1: bitmap_row = 8'b00111000;
            3'd0: bitmap_row = 8'b00000000;
        endcase
                // K
        5'd10: case (row)
            3'd0: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01000100;
            3'd2: bitmap_row = 8'b01001000;
            3'd3: bitmap_row = 8'b01110000;
            3'd4: bitmap_row = 8'b01001000;
            3'd5: bitmap_row = 8'b01000100;
            3'd6: bitmap_row = 8'b01000010;
            3'd7: bitmap_row = 8'b01000010;
            default: bitmap_row = 8'b00000000;
        endcase
        // L
        5'd11: case (row)
            3'd0: bitmap_row = 8'b01000000;
            3'd1: bitmap_row = 8'b01000000;
            3'd2: bitmap_row = 8'b01000000;
            3'd3: bitmap_row = 8'b01000000;
            3'd4: bitmap_row = 8'b01000000;
            3'd5: bitmap_row = 8'b01000000;
            3'd6: bitmap_row = 8'b01000000;
            3'd7: bitmap_row = 8'b01111110;
            default: bitmap_row = 8'b00000000;
        endcase
        // M
        5'd12: case (row)
            3'd0: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01100110;
            3'd2: bitmap_row = 8'b01011010;
            3'd3: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01000010;
            3'd5: bitmap_row = 8'b01000010;
            3'd6: bitmap_row = 8'b01000010;
            3'd7: bitmap_row = 8'b01000010;
            default: bitmap_row = 8'b00000000;
        endcase
        // N
        5'd13: case (row)
            3'd0: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01100010;
            3'd2: bitmap_row = 8'b01010010;
            3'd3: bitmap_row = 8'b01001010;
            3'd4: bitmap_row = 8'b01000110;
            3'd5: bitmap_row = 8'b01000010;
            3'd6: bitmap_row = 8'b01000010;
            3'd7: bitmap_row = 8'b01000010;
            default: bitmap_row = 8'b00000000;
        endcase
        // O
        5'd14: case (row)
            3'd0: bitmap_row = 8'b00111100;
            3'd1: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd3: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01000010;
            3'd5: bitmap_row = 8'b01000010;
            3'd6: bitmap_row = 8'b01000010;
            3'd7: bitmap_row = 8'b00111100;
            default: bitmap_row = 8'b00000000;
        endcase
        // P
        5'd15: case (row)
            3'd0: bitmap_row = 8'b01111100;
            3'd1: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd3: bitmap_row = 8'b01111100;
            3'd4: bitmap_row = 8'b01000000;
            3'd5: bitmap_row = 8'b01000000;
            3'd6: bitmap_row = 8'b01000000;
            3'd7: bitmap_row = 8'b01000000;
            default: bitmap_row = 8'b00000000;
        endcase
        // Q
        5'd16: case (row)
            3'd0: bitmap_row = 8'b00111100;
            3'd1: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd3: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01001010;
            3'd5: bitmap_row = 8'b01000100;
            3'd6: bitmap_row = 8'b00111010;
            3'd7: bitmap_row = 8'b00000010;
            default: bitmap_row = 8'b00000000;
        endcase
        // R
        5'd17: case (row)
            3'd0: bitmap_row = 8'b01111100;
            3'd1: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd3: bitmap_row = 8'b01111100;
            3'd4: bitmap_row = 8'b01001000;
            3'd5: bitmap_row = 8'b01000100;
            3'd6: bitmap_row = 8'b01000010;
            3'd7: bitmap_row = 8'b01000010;
            default: bitmap_row = 8'b00000000;
        endcase
        // S
        5'd18: case (row)
            3'd0: bitmap_row = 8'b00111100;
            3'd1: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000000;
            3'd3: bitmap_row = 8'b00111100;
            3'd4: bitmap_row = 8'b00000010;
            3'd5: bitmap_row = 8'b00000010;
            3'd6: bitmap_row = 8'b01000010;
            3'd7: bitmap_row = 8'b00111100;
            default: bitmap_row = 8'b00000000;
        endcase
        // T
        5'd19: case (row)
            3'd0: bitmap_row = 8'b01111110;
            3'd1: bitmap_row = 8'b00011000;
            3'd2: bitmap_row = 8'b00011000;
            3'd3: bitmap_row = 8'b00011000;
            3'd4: bitmap_row = 8'b00011000;
            3'd5: bitmap_row = 8'b00011000;
            3'd6: bitmap_row = 8'b00011000;
            3'd7: bitmap_row = 8'b00011000;
            default: bitmap_row = 8'b00000000;
        endcase
        // U
        5'd20: case (row)
            3'd0: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd3: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01000010;
            3'd5: bitmap_row = 8'b01000010;
            3'd6: bitmap_row = 8'b01000010;
            3'd7: bitmap_row = 8'b00111100;
            default: bitmap_row = 8'b00000000;
        endcase
        // V
        5'd21: case (row)
            3'd0: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd3: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01000010;
            3'd5: bitmap_row = 8'b00100100;
            3'd6: bitmap_row = 8'b00100100;
            3'd7: bitmap_row = 8'b00011000;
            default: bitmap_row = 8'b00000000;
        endcase
        // W
        5'd22: case (row)
            3'd0: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b01000010;
            3'd2: bitmap_row = 8'b01000010;
            3'd3: bitmap_row = 8'b01000010;
            3'd4: bitmap_row = 8'b01011010;
            3'd5: bitmap_row = 8'b01011010;
            3'd6: bitmap_row = 8'b01100110;
            3'd7: bitmap_row = 8'b01000010;
            default: bitmap_row = 8'b00000000;
        endcase
        // X
        5'd23: case (row)
            3'd0: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b00100100;
            3'd2: bitmap_row = 8'b00100100;
            3'd3: bitmap_row = 8'b00011000;
            3'd4: bitmap_row = 8'b00011000;
            3'd5: bitmap_row = 8'b00100100;
            3'd6: bitmap_row = 8'b00100100;
            3'd7: bitmap_row = 8'b01000010;
            default: bitmap_row = 8'b00000000;
        endcase
        // Y
        5'd24: case (row)
            3'd0: bitmap_row = 8'b01000010;
            3'd1: bitmap_row = 8'b00100100;
            3'd2: bitmap_row = 8'b00100100;
            3'd3: bitmap_row = 8'b00011000;
            3'd4: bitmap_row = 8'b00011000;
            3'd5: bitmap_row = 8'b00011000;
            3'd6: bitmap_row = 8'b00011000;
            3'd7: bitmap_row = 8'b00011000;
            default: bitmap_row = 8'b00000000;
        endcase
        // Z
        5'd25: case (row)
            3'd0: bitmap_row = 8'b01111110;
            3'd1: bitmap_row = 8'b00000010;
            3'd2: bitmap_row = 8'b00000100;
            3'd3: bitmap_row = 8'b00001000;
            3'd4: bitmap_row = 8'b00010000;
            3'd5: bitmap_row = 8'b00100000;
            3'd6: bitmap_row = 8'b01000000;
            3'd7: bitmap_row = 8'b01111110;
            default: bitmap_row = 8'b00000000;
        endcase
        default: bitmap_row = 8'b00000000;
    endcase
end

endmodule
