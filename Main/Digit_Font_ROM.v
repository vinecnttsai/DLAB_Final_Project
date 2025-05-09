module digit_font_rom (
    input wire [3:0] digit,     // 0~9
    input wire [2:0] row,       // 0~7
    output reg [7:0] bitmap_row // ¸Ó¦æªº8bit bitmap
);

(* rom_style = "block" *)

always @(*) begin
    case (digit)
        4'd0: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
            3'd6: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd5: bitmap_row = 8'b01000110; //  ¢i   ¢i¢i 
            3'd4: bitmap_row = 8'b01001010; //  ¢i  ¢i ¢i 
            3'd3: bitmap_row = 8'b01010010; //  ¢i ¢i  ¢i 
            3'd2: bitmap_row = 8'b01100010; //  ¢i¢i   ¢i 
            3'd1: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd0: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
        endcase
        4'd1: case (row)
            3'd7: bitmap_row = 8'b00011000; //    ¢i¢i   
            3'd6: bitmap_row = 8'b00101000; //   ¢i ¢i   
            3'd5: bitmap_row = 8'b01001000; //  ¢i  ¢i   
            3'd4: bitmap_row = 8'b00001000; //     ¢i   
            3'd3: bitmap_row = 8'b00001000; //     ¢i   
            3'd2: bitmap_row = 8'b00001000; //     ¢i   
            3'd1: bitmap_row = 8'b00001000; //     ¢i   
            3'd0: bitmap_row = 8'b01111110; //  ¢i¢i¢i¢i¢i¢i 
        endcase
        4'd2: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
            3'd6: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd5: bitmap_row = 8'b00000010; //       ¢i 
            3'd4: bitmap_row = 8'b00000100; //      ¢i  
            3'd3: bitmap_row = 8'b00001000; //     ¢i   
            3'd2: bitmap_row = 8'b00010000; //    ¢i    
            3'd1: bitmap_row = 8'b00100000; //   ¢i     
            3'd0: bitmap_row = 8'b01111110; //  ¢i¢i¢i¢i¢i¢i 
        endcase
        4'd3: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
            3'd6: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd5: bitmap_row = 8'b00000010; //       ¢i 
            3'd4: bitmap_row = 8'b00011100; //    ¢i¢i¢i  
            3'd3: bitmap_row = 8'b00000010; //       ¢i 
            3'd2: bitmap_row = 8'b00000010; //       ¢i 
            3'd1: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd0: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
        endcase
        4'd4: case (row)
            3'd7: bitmap_row = 8'b00000100; //      ¢i  
            3'd6: bitmap_row = 8'b00001100; //     ¢i¢i  
            3'd5: bitmap_row = 8'b00010100; //    ¢i ¢i  
            3'd4: bitmap_row = 8'b00100100; //   ¢i  ¢i  
            3'd3: bitmap_row = 8'b01000100; //  ¢i   ¢i  
            3'd2: bitmap_row = 8'b01111110; //  ¢i¢i¢i¢i¢i¢i 
            3'd1: bitmap_row = 8'b00000100; //      ¢i  
            3'd0: bitmap_row = 8'b00000100; //      ¢i  
        endcase
        4'd5: case (row)
            3'd7: bitmap_row = 8'b01111110; //  ¢i¢i¢i¢i¢i¢i 
            3'd6: bitmap_row = 8'b01000000; //  ¢i      
            3'd5: bitmap_row = 8'b01000000; //  ¢i      
            3'd4: bitmap_row = 8'b01111100; //  ¢i¢i¢i¢i¢i  
            3'd3: bitmap_row = 8'b00000010; //       ¢i 
            3'd2: bitmap_row = 8'b00000010; //       ¢i 
            3'd1: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd0: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
        endcase
        4'd6: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
            3'd6: bitmap_row = 8'b01000000; //  ¢i      
            3'd5: bitmap_row = 8'b01000000; //  ¢i      
            3'd4: bitmap_row = 8'b01111100; //  ¢i¢i¢i¢i¢i  
            3'd3: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd2: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd1: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd0: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
        endcase
        4'd7: case (row)
            3'd7: bitmap_row = 8'b01111110; //  ¢i¢i¢i¢i¢i¢i 
            3'd6: bitmap_row = 8'b00000010; //       ¢i 
            3'd5: bitmap_row = 8'b00000100; //      ¢i  
            3'd4: bitmap_row = 8'b00001000; //     ¢i   
            3'd3: bitmap_row = 8'b00010000; //    ¢i    
            3'd2: bitmap_row = 8'b00010000; //    ¢i    
            3'd1: bitmap_row = 8'b00010000; //    ¢i    
            3'd0: bitmap_row = 8'b00010000; //    ¢i    
        endcase
        4'd8: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
            3'd6: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd5: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd4: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
            3'd3: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd2: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd1: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd0: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
        endcase
        4'd9: case (row)
            3'd7: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
            3'd6: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd5: bitmap_row = 8'b01000010; //  ¢i    ¢i 
            3'd4: bitmap_row = 8'b00111110; //   ¢i¢i¢i¢i¢i 
            3'd3: bitmap_row = 8'b00000010; //       ¢i 
            3'd2: bitmap_row = 8'b00000010; //       ¢i 
            3'd1: bitmap_row = 8'b00000010; //       ¢i 
            3'd0: bitmap_row = 8'b00111100; //   ¢i¢i¢i¢i  
        endcase
        default: bitmap_row = 8'b00000000;
    endcase
end

endmodule
