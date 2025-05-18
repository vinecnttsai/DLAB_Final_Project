module tb_tb_vga;

    reg sys_clk = 0;
    reg sys_rst_n = 0;
    reg left_btn = 0;
    reg right_btn = 0;
    reg jump_btn = 0;
    reg sw = 0;

    wire hsync;
    wire vsync;
    wire [11:0] rgb;

    top uut (
        .sw(sw),
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .left_btn(left_btn),
        .right_btn(right_btn),
        .jump_btn(jump_btn),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );

   
always #1 sys_clk = ~sys_clk;

initial begin
    sys_clk = 0;
    sys_rst_n = 1;
    left_btn = 0;
    right_btn = 0;
    jump_btn = 0;
    sw = 0;

    #3 sys_rst_n = 0;
    #3 sys_rst_n = 1;

    #100000;
    sw = 1;
    #1000000000;
    $finish;
end


endmodule
