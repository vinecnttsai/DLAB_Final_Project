module tb_tb_char;

localparam PHY_WIDTH = 16;
localparam SIGNED_PHY_WIDTH = PHY_WIDTH + 1;
reg sys_clk;
reg sys_rst_n;
reg left_btn;
reg right_btn;
reg jump_btn;
wire [7*PHY_WIDTH-1:0] obstacle_abs_pos_x;
wire [7*PHY_WIDTH-1:0] obstacle_abs_pos_y;
wire [7*4-1:0] obstacle_block_width;
wire [7*PHY_WIDTH-1:0] obstacle_relative_pos_x;
wire [7*PHY_WIDTH-1:0] obstacle_relative_pos_y;
wire [SIGNED_PHY_WIDTH-1:0] out_pos_y;
wire character_clk;
wire [4:0] camera_y;

tb_character #(
    .INIT_POS_X(286),
    .INIT_POS_Y(682),
    .INIT_VEL_X(-1984),
    .INIT_VEL_Y(-256),
    .PHY_WIDTH(PHY_WIDTH)
) uut1
(
    .sys_clk(sys_clk),
    .character_clk(character_clk),
    .sys_rst_n(sys_rst_n),
    .left_btn(left_btn),
    .right_btn(right_btn),
    .jump_btn(jump_btn),
    .out_pos_y(out_pos_y),
    .obstacle_abs_pos_x(obstacle_abs_pos_x),
    .obstacle_abs_pos_y(obstacle_abs_pos_y),
    .obstacle_block_width(obstacle_block_width)
);

   genvar k;
    generate
        for (k = 0; k < 7; k = k + 1) begin : obstacle_abs_pos
            assign obstacle_abs_pos_x[k*PHY_WIDTH +: PHY_WIDTH] = obstacle_relative_pos_x[k*PHY_WIDTH +: PHY_WIDTH] + 120;
            assign obstacle_abs_pos_y[k*PHY_WIDTH +: PHY_WIDTH] = obstacle_relative_pos_y[k*PHY_WIDTH +: PHY_WIDTH] + camera_y * 480 + 0;
        end
    endgenerate


block_gen  #(
    .PHY_WIDTH(PHY_WIDTH)
) uut2
(
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .abs_char_y(out_pos_y),
    .camera_y(camera_y),
    .plat_relative_x(obstacle_relative_pos_x),
    .plat_relative_y(obstacle_relative_pos_y),
    .plat_len(obstacle_block_width)
);

fq_div #(.N(10)) fq_div1( // slowest clock : 100000000
    .org_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .div_n_clk(character_clk)
);

always #5 sys_clk = ~sys_clk;

initial begin
    sys_clk = 0;
    sys_rst_n = 1;
    left_btn = 0;
    right_btn = 0;
    jump_btn = 0;

    #3 sys_rst_n = 0;
    #3 sys_rst_n = 1;
    
    //#100 left_btn = 1;
    //#10000 left_btn = 0;
    #10000;
   #1000 jump_btn = 1;
   #20000 jump_btn = 0;

    #2000 right_btn = 1;
    #10 right_btn = 0;
    jump_btn = 1;
    #1000 jump_btn = 0;

    #1000000000;
    $finish;
end




endmodule
