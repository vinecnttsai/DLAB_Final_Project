module string_rom #(
    parameter STRING_NUM = 13,
    parameter MAX_CHAR = 11,
    parameter CHAR_WIDTH = 5
)
(
    input wire [$clog2(STRING_NUM + 1) - 1:0] addr,
    output reg [CHAR_WIDTH*MAX_CHAR-1:0] string_out
);

// Number of strings: 13
// Each string is MAX_CHAR characters
// Unknown characters are replaced with space (5'd31)

(*rom_style = "block"*) reg [CHAR_WIDTH*MAX_CHAR*STRING_NUM-1:0] string_rom = {
    5'd8, 5'd13, 5'd18, 5'd19, 5'd17, 5'd20, 5'd2, 5'd19, 5'd8, 5'd14, 5'd13,
    5'd15, 5'd28, 5'd30, 5'd26, 5'd31, 5'd11, 5'd4, 5'd5, 5'd19, 5'd31, 5'd31,
    5'd13, 5'd28, 5'd30, 5'd26, 5'd31, 5'd9, 5'd20, 5'd12, 5'd15, 5'd31, 5'd31,
    5'd12, 5'd28, 5'd30, 5'd26, 5'd31, 5'd17, 5'd8, 5'd6, 5'd7, 5'd19, 5'd31,
    5'd12, 5'd28, 5'd31, 5'd26, 5'd31, 5'd17, 5'd4, 5'd18, 5'd4, 5'd19, 5'd31,
    5'd27, 5'd27, 5'd27, 5'd27, 5'd27, 5'd27, 5'd27, 5'd27, 5'd27, 5'd27, 5'd27,
    5'd6, 5'd0, 5'd12, 5'd4, 5'd31, 5'd18, 5'd19, 5'd0, 5'd19, 5'd20, 5'd18,
    5'd5, 5'd0, 5'd11, 5'd11, 5'd31, 5'd2, 5'd14, 5'd20, 5'd13, 5'd19, 5'd26,
    5'd24, 5'd31, 5'd21, 5'd4, 5'd11, 5'd14, 5'd2, 5'd8, 5'd19, 5'd24, 5'd26,
    5'd23, 5'd31, 5'd21, 5'd4, 5'd11, 5'd14, 5'd2, 5'd8, 5'd19, 5'd24, 5'd26,
    5'd24, 5'd31, 5'd15, 5'd14, 5'd18, 5'd8, 5'd19, 5'd8, 5'd14, 5'd13, 5'd26,
    5'd23, 5'd31, 5'd15, 5'd14, 5'd18, 5'd8, 5'd19, 5'd8, 5'd14, 5'd13, 5'd26,
    5'd6, 5'd0, 5'd12, 5'd4, 5'd31, 5'd19, 5'd8, 5'd12, 5'd4, 5'd26, 5'd31
};

always @(*) begin
    string_out = string_rom[addr*CHAR_WIDTH*MAX_CHAR +: CHAR_WIDTH*MAX_CHAR];
end

endmodule
