module debug_var #(parameter SEQ_LEN = 16,
                   parameter PIXEL_WIDTH = 12,
                   parameter FONT_WIDTH = 8, 
                   parameter SEQ_DIGIT = SEQ_LEN / 4 + 1 // 1 for sign digit
                   )(
    input [SEQ_LEN - 1:0] seq,
    output [SEQ_DIGIT * (FONT_WIDTH * FONT_WIDTH) * PIXEL_WIDTH - 1:0] debug_seq
);

wire [SEQ_LEN - 1:0] seq_2scomplement;
wire [SEQ_LEN - 1:0] seq_bcd;

assign seq_2scomplement = seq[SEQ_LEN - 1] ? ~seq + 1 : seq;

bin_to_bcd_converter #(.DIGITS(SEQ_DIGIT)) uut1 (
    .in(seq_2scomplement),
    .out(seq_bcd)
);


genvar i;
generate
    for (i = 0; i < FONT_WIDTH; i = i + 1) begin : DIGIT_SPLIT
        seq_font_rom #(.SEQ_LEN(SEQ_LEN), .SEQ_DIGIT(SEQ_DIGIT), .PIXEL_WIDTH(PIXEL_WIDTH), .FONT_WIDTH(FONT_WIDTH)) uut2 (
            .seq(seq_bcd),
            .sign(seq[SEQ_LEN - 1]),
            .row(i),
            .line_pixels(debug_seq[i * SEQ_DIGIT * FONT_WIDTH * PIXEL_WIDTH +: SEQ_DIGIT * FONT_WIDTH * PIXEL_WIDTH])
        );
    end
endgenerate

endmodule

module seq_font_rom #(
    parameter SEQ_LEN = 16,  // SEQ_LEN must be a multiple of 4, such as 16, 32
    parameter SEQ_DIGIT = SEQ_LEN / 4 + 1, // 1 for sign digit
    parameter PIXEL_WIDTH = 12,
    parameter FONT_WIDTH = 8
) (
    input [SEQ_LEN - 1:0] seq,          // SEQ_LEN - bit seq
    input [$clog2(FONT_WIDTH) - 1:0] row,                 // which row 0~7
    input sign, // 1 for negative, 0 for positive
    output [SEQ_DIGIT * FONT_WIDTH * PIXEL_WIDTH - 1:0] line_pixels  // output one line of pixels
);

wire [3:0] digits [SEQ_DIGIT - 1:0];
genvar i, k;
generate
    for (i = 0; i < SEQ_DIGIT - 1; i = i + 1) begin : DIGIT_SPLIT
        assign digits[i] = seq[i * 4 +: 4]; // split from high to low
    end
    assign digits[SEQ_DIGIT - 1] = sign ? 4'ha : 4'h0;
endgenerate

wire [FONT_WIDTH - 1:0] digit_line [SEQ_DIGIT - 1:0];
generate
    for (i = 0; i < SEQ_DIGIT; i = i + 1) begin : DIGIT_FONT
        digit_font_rom_8 uut (
            .digit(digits[i]),
            .row(row),
            .bitmap_row(digit_line[i])
        );
    end
endgenerate

generate
    for (i = 0; i < SEQ_DIGIT; i = i + 1) begin : COMBINE_DIGITS
        for (k = 0; k < FONT_WIDTH; k = k + 1) begin : PIXEL_SPLIT
            assign line_pixels[(i * FONT_WIDTH + k) * PIXEL_WIDTH +: PIXEL_WIDTH] = (digit_line[i][k] == 1) ? {PIXEL_WIDTH{1'b0}} : {PIXEL_WIDTH{1'b1}}; // 黑色 / 白色
        end
    end
endgenerate

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
