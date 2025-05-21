module bcd_seq_display_controller #(
    parameter SCREEN_WIDTH = 10,
    parameter SEQ_LEN = 20,
    parameter SEQ_DIGITS = (SEQ_LEN >>> 2) + 1,
    parameter PIXEL_WIDTH = 12,
    parameter FONT_WIDTH = 8
)(
    input [SEQ_LEN - 1:0] seq,
    input [SCREEN_WIDTH - 1:0] seq_x_rom,
    input [SCREEN_WIDTH - 1:0] seq_y_rom,
    input [PIXEL_WIDTH - 1:0] background_rgb,
    output reg [PIXEL_WIDTH - 1:0] rgb
);
localparam BCD_COLOR = 12'hFFF;
localparam BCD_WIDTH = 4;

wire [SEQ_LEN - 1:0] bcd_seq;
wire [FONT_WIDTH - 1:0] row_rgb_id;
reg [$clog2(SEQ_DIGITS + 1) - 1:0] which_digit;
reg [$clog2(FONT_WIDTH + 1) - 1:0] col;
reg [BCD_WIDTH - 1:0] digit;

always @(*) begin
    if(which_digit == SEQ_DIGITS - 1) begin // sign digit
        digit = (bcd_seq[SEQ_LEN - BCD_WIDTH +: BCD_WIDTH]) ? 4'hA : 4'hB; // 9 for -, A for blank
    end else begin
        digit = bcd_seq[which_digit * BCD_WIDTH +: BCD_WIDTH];
    end
end

always @(*) begin
    which_digit = seq_x_rom >>> 3; // seq_x_rom / 4
    col = seq_x_rom % FONT_WIDTH;
end

always @(*) begin
    rgb = (row_rgb_id[col]) ? BCD_COLOR : background_rgb;
end

bin_to_bcd_converter #(.DIGITS(SEQ_DIGITS-1)) bin_to_bcd_converter_inst(
    .in(seq),
    .out(bcd_seq)
);

digit_font_rom_8 digit_font_rom_8_inst(
    .digit(digit),
    .row(seq_y_rom),
    .bitmap_row(row_rgb_id)
);

endmodule

module digit_font_rom_8 (
    input [3:0] digit,     // 0~9
    input [2:0] row,       // 0~7
    output reg [7:0] bitmap_row // 該行的8bit bitmap
);

(* rom_style = "block" *)

always @( * ) begin
    case (digit)
        4'd0: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ████  
            3'd6: bitmap_row = 8'b01000010; //  █    █ 
            3'd5: bitmap_row = 8'b01000110; //  █   ██ 
            3'd4: bitmap_row = 8'b01001010; //  █  █ █ 
            3'd3: bitmap_row = 8'b01010010; //  █ █  █ 
            3'd2: bitmap_row = 8'b01100010; //  ██   █ 
            3'd1: bitmap_row = 8'b01000010; //  █    █ 
            3'd0: bitmap_row = 8'b00111100; //   ████  
            default: bitmap_row = 8'b00000000;
        endcase
        4'd1: case (row)
            3'd7: bitmap_row = 8'b00011000; //    ██   
            3'd6: bitmap_row = 8'b00101000; //   █ █   
            3'd5: bitmap_row = 8'b01001000; //  █  █   
            3'd4: bitmap_row = 8'b00001000; //     █   
            3'd3: bitmap_row = 8'b00001000; //     █   
            3'd2: bitmap_row = 8'b00001000; //     █   
            3'd1: bitmap_row = 8'b00001000; //     █   
            3'd0: bitmap_row = 8'b01111110; //  ██████ 
            default: bitmap_row = 8'b00000000;
        endcase
        4'd2: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ████  
            3'd6: bitmap_row = 8'b01000010; //  █    █ 
            3'd5: bitmap_row = 8'b00000010; //       █ 
            3'd4: bitmap_row = 8'b00000100; //      █  
            3'd3: bitmap_row = 8'b00001000; //     █   
            3'd2: bitmap_row = 8'b00010000; //    █    
            3'd1: bitmap_row = 8'b00100000; //   █     
            3'd0: bitmap_row = 8'b01111110; //  ██████ 
            default: bitmap_row = 8'b00000000;
        endcase
        4'd3: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ████  
            3'd6: bitmap_row = 8'b01000010; //  █    █ 
            3'd5: bitmap_row = 8'b00000010; //       █ 
            3'd4: bitmap_row = 8'b00011100; //    ███  
            3'd3: bitmap_row = 8'b00000010; //       █ 
            3'd2: bitmap_row = 8'b00000010; //       █ 
            3'd1: bitmap_row = 8'b01000010; //  █    █ 
            3'd0: bitmap_row = 8'b00111100; //   ████  
            default: bitmap_row = 8'b00000000;
        endcase
        4'd4: case (row)
            3'd7: bitmap_row = 8'b00000100; //      █  
            3'd6: bitmap_row = 8'b00001100; //     ██  
            3'd5: bitmap_row = 8'b00010100; //    █ █  
            3'd4: bitmap_row = 8'b00100100; //   █  █  
            3'd3: bitmap_row = 8'b01000100; //  █   █  
            3'd2: bitmap_row = 8'b01111110; //  ██████ 
            3'd1: bitmap_row = 8'b00000100; //      █  
            3'd0: bitmap_row = 8'b00000100; //      █  
            default: bitmap_row = 8'b00000000;
        endcase
        4'd5: case (row)
            3'd7: bitmap_row = 8'b01111110; //  ██████ 
            3'd6: bitmap_row = 8'b01000000; //  █      
            3'd5: bitmap_row = 8'b01000000; //  █      
            3'd4: bitmap_row = 8'b01111100; //  █████  
            3'd3: bitmap_row = 8'b00000010; //       █ 
            3'd2: bitmap_row = 8'b00000010; //       █ 
            3'd1: bitmap_row = 8'b01000010; //  █    █ 
            3'd0: bitmap_row = 8'b00111100; //   ████  
            default: bitmap_row = 8'b00000000;
        endcase
        4'd6: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ████  
            3'd6: bitmap_row = 8'b01000000; //  █      
            3'd5: bitmap_row = 8'b01000000; //  █      
            3'd4: bitmap_row = 8'b01111100; //  █████  
            3'd3: bitmap_row = 8'b01000010; //  █    █ 
            3'd2: bitmap_row = 8'b01000010; //  █    █ 
            3'd1: bitmap_row = 8'b01000010; //  █    █ 
            3'd0: bitmap_row = 8'b00111100; //   ████  
            default: bitmap_row = 8'b00000000;
        endcase
        4'd7: case (row)
            3'd7: bitmap_row = 8'b01111110; //  ██████ 
            3'd6: bitmap_row = 8'b00000010; //       █ 
            3'd5: bitmap_row = 8'b00000100; //      █  
            3'd4: bitmap_row = 8'b00001000; //     █   
            3'd3: bitmap_row = 8'b00010000; //    █    
            3'd2: bitmap_row = 8'b00010000; //    █    
            3'd1: bitmap_row = 8'b00010000; //    █    
            3'd0: bitmap_row = 8'b00010000; //    █    
            default: bitmap_row = 8'b00000000;
        endcase
        4'd8: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ████  
            3'd6: bitmap_row = 8'b01000010; //  █    █ 
            3'd5: bitmap_row = 8'b01000010; //  █    █ 
            3'd4: bitmap_row = 8'b00111100; //   ████  
            3'd3: bitmap_row = 8'b01000010; //  █    █ 
            3'd2: bitmap_row = 8'b01000010; //  █    █ 
            3'd1: bitmap_row = 8'b01000010; //  █    █ 
            3'd0: bitmap_row = 8'b00111100; //   ████  
            default: bitmap_row = 8'b00000000;
        endcase
        4'd9: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ████  
            3'd6: bitmap_row = 8'b01000010; //  █    █ 
            3'd5: bitmap_row = 8'b01000010; //  █    █ 
            3'd4: bitmap_row = 8'b00111110; //   █████ 
            3'd3: bitmap_row = 8'b00000010; //       █ 
            3'd2: bitmap_row = 8'b00000010; //       █ 
            3'd1: bitmap_row = 8'b00000010; //       █ 
            3'd0: bitmap_row = 8'b00111100; //   ████  
            default: bitmap_row = 8'b00000000;
        endcase
        4'd10: case (row) // minius sign
            3'd7: bitmap_row = 8'b00000000; //
            3'd6: bitmap_row = 8'b00000000; //
            3'd5: bitmap_row = 8'b00000000; // 
            3'd4: bitmap_row = 8'b00000000; //  
            3'd3: bitmap_row = 8'b01111110; //  ██████      
            3'd2: bitmap_row = 8'b00000000; //
            3'd1: bitmap_row = 8'b00000000; //
            3'd0: bitmap_row = 8'b00000000; //
            default: bitmap_row = 8'b00000000;
        endcase
        default: bitmap_row = 8'b00000000;
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
