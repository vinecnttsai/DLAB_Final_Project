module tb_tb_vga;

    reg sys_clk;
    reg sys_rst_n;
    reg left_btn;
    reg right_btn;
    reg jump_btn;
    wire hsync;
    wire vsync;
    wire [11:0] rgb;

    top uut(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .left_btn(left_btn),
        .right_btn(right_btn),
        .jump_btn(jump_btn),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );

    // Reset
    initial begin
        sys_clk = 0;
        sys_rst_n = 0;
        left_btn = 0;
        right_btn = 0;
        jump_btn = 0;
        #10 sys_rst_n = 1;

        #1000000000 $finish;
    end

    always #5 sys_clk = ~sys_clk;

endmodule
