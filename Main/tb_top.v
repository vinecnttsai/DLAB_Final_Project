module tb_tb_vga;

    reg sys_clk = 0;
    reg sys_rst_n = 0;
    reg up = 0;
    reg down = 0;
    reg left = 0;
    reg right = 0;
    reg jump = 0;


    wire hsync;
    wire vsync;
    wire [11:0] rgb;

    top_debug uut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .jump(jump),
        .hsync(hsync),
        .vsync(vsync),
        .rgb(rgb)
    );

   
always #1 sys_clk = ~sys_clk;

initial begin
    sys_clk = 0;
    sys_rst_n = 1;
    up = 0;
    down = 0;
    left = 0;
    right = 0;
    jump = 0;

    #3 sys_rst_n = 0;
    #3 sys_rst_n = 1;

    //#100 left = 1;
    //#10000 left = 0;
    #10000;
    #1000 jump = 1;
    #20000 jump = 0;

    #2000 right = 1;
    #10 right = 0;
    jump = 1;
    #1000 jump = 0;

    $finish;
end


endmodule
