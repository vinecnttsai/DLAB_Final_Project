module tb_tb_vga;

    reg sys_clk = 0;
    reg sys_rst_n = 0;
    reg sw = 0;
    reg up = 0;
    reg down = 0;

    wire hsync;
    wire vsync;
    wire [11:0] rgb;

    top uut (
        .sw(sw),
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .up(up),
        .down(down),
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
    sw = 0;

    #3 sys_rst_n = 0;
    #3 sys_rst_n = 1;

    #1000000;
    up = 1;
    #100;
    up = 0;
    #100;
    up = 1;
    #100;
    up = 0;

    #100000;
    sw = 1;
    #1000000000;
    $finish;
end


endmodule
