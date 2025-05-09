module b2d_converter #(
    parameter DIGITS = 4
)(
    input  [(DIGITS*4)-1:0] in,
    output reg  [(DIGITS*4)-1:0] out
);

    localparam N = DIGITS * 4;
    integer i, j;
    reg [N + DIGITS*4 - 1:0] shift_reg;

    always @(*) begin
        shift_reg = 0;
        shift_reg[N-1:0] = in;

        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < DIGITS; j = j + 1) begin
                if (shift_reg[N + j*4 +: 4] >= 5)
                    shift_reg[N + j*4 +: 4] = shift_reg[N + j*4 +: 4] + 3;
            end
            shift_reg = shift_reg << 1;
        end

        for (j = 0; j < DIGITS; j = j + 1) begin
            out[j*4 +: 4] = shift_reg[N + j*4 +: 4];
        end
    end
endmodule