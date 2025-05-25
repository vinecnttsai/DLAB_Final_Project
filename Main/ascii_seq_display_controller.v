module ascii_seq_display_controller #(
    parameter SCREEN_WIDTH = 10,
    parameter MAX_CHAR_NUM = 11,
    parameter CHAR_WIDTH = 5,
    parameter PIXEL_WIDTH = 12,
    parameter FONT_WIDTH = 8
)(
    input seq_on,
    input [MAX_CHAR_NUM * CHAR_WIDTH - 1:0] seq,
    input [SCREEN_WIDTH - 1:0] seq_x_rom,
    input [SCREEN_WIDTH - 1:0] seq_y_rom,
    input [PIXEL_WIDTH - 1:0] background_rgb,
    output reg [PIXEL_WIDTH - 1:0] rgb
);
localparam CHAR_COLOR = 12'h5FF;

reg [SCREEN_WIDTH - 1:0] seq_x_rom_safe;
reg [SCREEN_WIDTH - 1:0] seq_y_rom_safe;
wire [FONT_WIDTH - 1:0] row_rgb_id;
reg [$clog2(MAX_CHAR_NUM + 1) - 1:0] which_char;
reg [$clog2(FONT_WIDTH + 1) - 1:0] col;
reg [CHAR_WIDTH - 1:0] char;

always @(*) begin
    char = seq[which_char * CHAR_WIDTH +: CHAR_WIDTH];
end

always @(*) begin
    seq_x_rom_safe = (seq_on) ? seq_x_rom : 0;
    seq_y_rom_safe = (seq_on) ? seq_y_rom : 0;
end

always @(*) begin
    which_char = seq_x_rom_safe >>> 3; // seq_x_rom / 8
    col = seq_x_rom_safe % FONT_WIDTH;
end

always @(*) begin
    rgb = (row_rgb_id[col]) ? CHAR_COLOR : background_rgb;
end

alphabet_font_rom_8 alphabet_font_rom_8_inst(
    .char_idx(char),
    .row(seq_y_rom),
    .bitmap_row(row_rgb_id)
);

endmodule

module alphabet_font_rom_8 (
    input [4:0] char_idx,
    input [2:0] row,
    output reg [7:0] bitmap_row
);

always @(*) begin
    case (char_idx)
        5'd0: case(row) // A
            3'd7: bitmap_row = 8'b00011000; //    ██    
            3'd6: bitmap_row = 8'b00111100; //   ████   
            3'd5: bitmap_row = 8'b01100110; //  ██  ██  
            3'd4: bitmap_row = 8'b01111110; //  ██████  
            3'd3: bitmap_row = 8'b01100110; //  ██  ██  
            3'd2: bitmap_row = 8'b01100110; //  ██  ██  
            3'd1: bitmap_row = 8'b01100110; //  ██  ██  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd1: case(row) // B
            3'd7: bitmap_row = 8'b01111000; //  ████    
            3'd6: bitmap_row = 8'b01100100; //  ██  █   
            3'd5: bitmap_row = 8'b01100100; //  ██  █   
            3'd4: bitmap_row = 8'b01111000; //  ████    
            3'd3: bitmap_row = 8'b01100100; //  ██  █   
            3'd2: bitmap_row = 8'b01100100; //  ██  █   
            3'd1: bitmap_row = 8'b01111000; //  ████    
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd2: case(row) // C
            3'd7: bitmap_row = 8'b00111100; //   ████   
            3'd6: bitmap_row = 8'b01100010; //  ██   █  
            3'd5: bitmap_row = 8'b01100000; //  ██      
            3'd4: bitmap_row = 8'b01100000; //  ██      
            3'd3: bitmap_row = 8'b01100000; //  ██      
            3'd2: bitmap_row = 8'b01100010; //  ██   █  
            3'd1: bitmap_row = 8'b00111100; //   ████   
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd3: case(row) // D
            3'd7: bitmap_row = 8'b01111000; //  ████    
            3'd6: bitmap_row = 8'b01100100; //  ██  █   
            3'd5: bitmap_row = 8'b01100010; //  ██   █  
            3'd4: bitmap_row = 8'b01100010; //  ██   █  
            3'd3: bitmap_row = 8'b01100010; //  ██   █  
            3'd2: bitmap_row = 8'b01100100; //  ██  █   
            3'd1: bitmap_row = 8'b01111000; //  ████    
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd4: case(row) // E
            3'd7: bitmap_row = 8'b01111110; //  ██████  
            3'd6: bitmap_row = 8'b01100000; //  ██      
            3'd5: bitmap_row = 8'b01100000; //  ██      
            3'd4: bitmap_row = 8'b01111100; //  █████   
            3'd3: bitmap_row = 8'b01100000; //  ██      
            3'd2: bitmap_row = 8'b01100000; //  ██      
            3'd1: bitmap_row = 8'b01111110; //  ██████  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd5: case(row) // F
            3'd7: bitmap_row = 8'b01111110; //  ██████  
            3'd6: bitmap_row = 8'b01100000; //  ██      
            3'd5: bitmap_row = 8'b01100000; //  ██      
            3'd4: bitmap_row = 8'b01111100; //  █████   
            3'd3: bitmap_row = 8'b01100000; //  ██      
            3'd2: bitmap_row = 8'b01100000; //  ██      
            3'd1: bitmap_row = 8'b01100000; //  ██      
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd6: case(row) // G
            3'd7: bitmap_row = 8'b00111100; //   ████   
            3'd6: bitmap_row = 8'b01100010; //  ██   █  
            3'd5: bitmap_row = 8'b01100000; //  ██      
            3'd4: bitmap_row = 8'b01101110; //  ██ ███  
            3'd3: bitmap_row = 8'b01100010; //  ██   █  
            3'd2: bitmap_row = 8'b01100010; //  ██   █  
            3'd1: bitmap_row = 8'b00111100; //   ████   
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd7: case(row) // H
            3'd7: bitmap_row = 8'b01100110; //  ██  ██  
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01100110; //  ██  ██  
            3'd4: bitmap_row = 8'b01111110; //  ██████  
            3'd3: bitmap_row = 8'b01100110; //  ██  ██  
            3'd2: bitmap_row = 8'b01100110; //  ██  ██  
            3'd1: bitmap_row = 8'b01100110; //  ██  ██  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd8: case(row) // I
            3'd7: bitmap_row = 8'b00111100; //   ████   
            3'd6: bitmap_row = 8'b00011000; //    ██    
            3'd5: bitmap_row = 8'b00011000; //    ██    
            3'd4: bitmap_row = 8'b00011000; //    ██    
            3'd3: bitmap_row = 8'b00011000; //    ██    
            3'd2: bitmap_row = 8'b00011000; //    ██    
            3'd1: bitmap_row = 8'b00111100; //   ████   
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd9: case(row) // J
            3'd7: bitmap_row = 8'b00011110; //    ████  
            3'd6: bitmap_row = 8'b00001100; //     ██   
            3'd5: bitmap_row = 8'b00001100; //     ██   
            3'd4: bitmap_row = 8'b00001100; //     ██   
            3'd3: bitmap_row = 8'b01001100; //  █  ██   
            3'd2: bitmap_row = 8'b01001100; //  █  ██   
            3'd1: bitmap_row = 8'b00111000; //   ███    
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd10: case(row) // K
            3'd7: bitmap_row = 8'b01100110; //  ██  ██  
            3'd6: bitmap_row = 8'b01101100; //  ██ ██   
            3'd5: bitmap_row = 8'b01111000; //  ████    
            3'd4: bitmap_row = 8'b01110000; //  ███     
            3'd3: bitmap_row = 8'b01111000; //  ████    
            3'd2: bitmap_row = 8'b01101100; //  ██ ██   
            3'd1: bitmap_row = 8'b01100110; //  ██  ██  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd11: case(row) // L
            3'd7: bitmap_row = 8'b01100000; //  ██      
            3'd6: bitmap_row = 8'b01100000; //  ██      
            3'd5: bitmap_row = 8'b01100000; //  ██      
            3'd4: bitmap_row = 8'b01100000; //  ██      
            3'd3: bitmap_row = 8'b01100000; //  ██      
            3'd2: bitmap_row = 8'b01100000; //  ██      
            3'd1: bitmap_row = 8'b01111110; //  ██████  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd12: case(row) // M
            3'd7: bitmap_row = 8'b01000010; //  █    █  
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01111110; //  ██████  
            3'd4: bitmap_row = 8'b01011010; //  █ ██ █  
            3'd3: bitmap_row = 8'b01000010; //  █    █  
            3'd2: bitmap_row = 8'b01000010; //  █    █  
            3'd1: bitmap_row = 8'b01000010; //  █    █  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd13: case(row) // N
            3'd7: bitmap_row = 8'b01000110; //  █   ██  
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01110110; //  ███ ██  
            3'd4: bitmap_row = 8'b01111110; //  ██████  
            3'd3: bitmap_row = 8'b01101110; //  ██ ███  
            3'd2: bitmap_row = 8'b01100110; //  ██  ██  
            3'd1: bitmap_row = 8'b01100010; //  ██   █  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd14: case(row) // O
            3'd7: bitmap_row = 8'b00111100; //   ████   
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01100110; //  ██  ██  
            3'd4: bitmap_row = 8'b01100110; //  ██  ██  
            3'd3: bitmap_row = 8'b01100110; //  ██  ██  
            3'd2: bitmap_row = 8'b01100110; //  ██  ██  
            3'd1: bitmap_row = 8'b00111100; //   ████   
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd15: case(row) // P
            3'd7: bitmap_row = 8'b01111100; //  █████   
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01100110; //  ██  ██  
            3'd4: bitmap_row = 8'b01111100; //  █████   
            3'd3: bitmap_row = 8'b01100000; //  ██      
            3'd2: bitmap_row = 8'b01100000; //  ██      
            3'd1: bitmap_row = 8'b01100000; //  ██      
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd16: case(row) // Q
            3'd7: bitmap_row = 8'b00111100; //   ████   
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01100110; //  ██  ██  
            3'd4: bitmap_row = 8'b01100110; //  ██  ██  
            3'd3: bitmap_row = 8'b01101110; //  ██ ███  
            3'd2: bitmap_row = 8'b01100110; //  ██  ██  
            3'd1: bitmap_row = 8'b00111110; //   █████  
            3'd0: bitmap_row = 8'b00000010; //       █  
            default: bitmap_row = 8'b00000000;
        endcase
        5'd17: case(row) // R
            3'd7: bitmap_row = 8'b01111100; //  █████   
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01100110; //  ██  ██  
            3'd4: bitmap_row = 8'b01111100; //  █████   
            3'd3: bitmap_row = 8'b01111000; //  ████    
            3'd2: bitmap_row = 8'b01101100; //  ██ ██   
            3'd1: bitmap_row = 8'b01100110; //  ██  ██  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd18: case(row) // S
            3'd7: bitmap_row = 8'b00111100; //   ████   
            3'd6: bitmap_row = 8'b01100010; //  ██   █  
            3'd5: bitmap_row = 8'b01110000; //  ███     
            3'd4: bitmap_row = 8'b00111000; //   ███    
            3'd3: bitmap_row = 8'b00011100; //    ███   
            3'd2: bitmap_row = 8'b01001110; //  █  ███  
            3'd1: bitmap_row = 8'b00111100; //   ████   
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd19: case(row) // T
            3'd7: bitmap_row = 8'b01111110; //  ██████  
            3'd6: bitmap_row = 8'b00011000; //    ██    
            3'd5: bitmap_row = 8'b00011000; //    ██    
            3'd4: bitmap_row = 8'b00011000; //    ██    
            3'd3: bitmap_row = 8'b00011000; //    ██    
            3'd2: bitmap_row = 8'b00011000; //    ██    
            3'd1: bitmap_row = 8'b00011000; //    ██    
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd20: case(row) // U
            3'd7: bitmap_row = 8'b01100110; //  ██  ██  
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01100110; //  ██  ██  
            3'd4: bitmap_row = 8'b01100110; //  ██  ██  
            3'd3: bitmap_row = 8'b01100110; //  ██  ██  
            3'd2: bitmap_row = 8'b01100110; //  ██  ██  
            3'd1: bitmap_row = 8'b00111100; //   ████   
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd21: case(row) // V
            3'd7: bitmap_row = 8'b01100110; //  ██  ██  
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01100110; //  ██  ██  
            3'd4: bitmap_row = 8'b01100110; //  ██  ██  
            3'd3: bitmap_row = 8'b01100110; //  ██  ██  
            3'd2: bitmap_row = 8'b00111100; //   ████   
            3'd1: bitmap_row = 8'b00011000; //    ██    
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd22: case(row) // W
            3'd7: bitmap_row = 8'b01000010; //  █    █  
            3'd6: bitmap_row = 8'b01000010; //  █    █  
            3'd5: bitmap_row = 8'b01000010; //  █    █  
            3'd4: bitmap_row = 8'b01011010; //  █ ██ █  
            3'd3: bitmap_row = 8'b01111110; //  ██████  
            3'd2: bitmap_row = 8'b01100110; //  ██  ██  
            3'd1: bitmap_row = 8'b01000010; //  █    █  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd23: case(row) // X
            3'd7: bitmap_row = 8'b01100110; //  ██  ██  
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b00111100; //   ████   
            3'd4: bitmap_row = 8'b00011000; //    ██    
            3'd3: bitmap_row = 8'b00111100; //   ████   
            3'd2: bitmap_row = 8'b01100110; //  ██  ██  
            3'd1: bitmap_row = 8'b01100110; //  ██  ██  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd24: case(row) // Y
            3'd7: bitmap_row = 8'b01100110; //  ██  ██  
            3'd6: bitmap_row = 8'b01100110; //  ██  ██  
            3'd5: bitmap_row = 8'b01100110; //  ██  ██  
            3'd4: bitmap_row = 8'b00111100; //   ████   
            3'd3: bitmap_row = 8'b00011000; //    ██    
            3'd2: bitmap_row = 8'b00011000; //    ██    
            3'd1: bitmap_row = 8'b00011000; //    ██    
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd25: case(row) // Z
            3'd7: bitmap_row = 8'b01111110; //  ██████  
            3'd6: bitmap_row = 8'b00000110; //      ██  
            3'd5: bitmap_row = 8'b00001100; //     ██   
            3'd4: bitmap_row = 8'b00011000; //    ██    
            3'd3: bitmap_row = 8'b00110000; //   ██     
            3'd2: bitmap_row = 8'b01100000; //  ██      
            3'd1: bitmap_row = 8'b01111110; //  ██████  
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd26: case(row) // :
            3'd7: bitmap_row = 8'b00000000; //          
            3'd6: bitmap_row = 8'b00011000; //    ██    
            3'd5: bitmap_row = 8'b00011000; //    ██    
            3'd4: bitmap_row = 8'b00000000; //          
            3'd3: bitmap_row = 8'b00000000; //          
            3'd2: bitmap_row = 8'b00011000; //    ██    
            3'd1: bitmap_row = 8'b00011000; //    ██    
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd27: case(row) // =
            3'd7: bitmap_row = 8'b00000000; //          
            3'd6: bitmap_row = 8'b00000000; //          
            3'd5: bitmap_row = 8'b01111110; //  ██████  
            3'd4: bitmap_row = 8'b00000000; //          
            3'd3: bitmap_row = 8'b01111110; //  ██████  
            3'd2: bitmap_row = 8'b00000000; //          
            3'd1: bitmap_row = 8'b00000000; //          
            3'd0: bitmap_row = 8'b00000000; //          
            default: bitmap_row = 8'b00000000;
        endcase
        5'd28: case (row) // 1
            3'd7: bitmap_row = 8'b00111000; //   ███   
            3'd6: bitmap_row = 8'b01111000; //  ████   
            3'd5: bitmap_row = 8'b00111000; //   ███   
            3'd4: bitmap_row = 8'b00111000; //   ███   
            3'd3: bitmap_row = 8'b00111000; //   ███   
            3'd2: bitmap_row = 8'b00111000; //   ███   
            3'd1: bitmap_row = 8'b00111000; //   ███   
            3'd0: bitmap_row = 8'b11111110; // ███████ 
            default: bitmap_row = 8'b00000000;
        endcase
        5'd29: case (row)
            3'd7: bitmap_row = 8'b01111100; //  █████  
            3'd6: bitmap_row = 8'b11000110; // ██   ██ 
            3'd5: bitmap_row = 8'b00000110; //      ██ 
            3'd4: bitmap_row = 8'b00011100; //    ███  
            3'd3: bitmap_row = 8'b00111000; //   ███   
            3'd2: bitmap_row = 8'b01110000; //  ███    
            3'd1: bitmap_row = 8'b11100000; // ███     
            3'd0: bitmap_row = 8'b11111110; // ███████ 
            default: bitmap_row = 8'b00000000;
        endcase
        5'd30: case (row)
            3'd7: bitmap_row = 8'b11111110; // ███████ 
            3'd6: bitmap_row = 8'b00000110; //      ██ 
            3'd5: bitmap_row = 8'b00001100; //     ██  
            3'd4: bitmap_row = 8'b00011000; //    ██   
            3'd3: bitmap_row = 8'b00110000; //   ██    
            3'd2: bitmap_row = 8'b00110000; //   ██    
            3'd1: bitmap_row = 8'b00110000; //   ██    
            3'd0: bitmap_row = 8'b00110000; //   ██    
            default: bitmap_row = 8'b00000000;
        endcase
        default: bitmap_row = 8'b00000000;
    endcase
end

endmodule