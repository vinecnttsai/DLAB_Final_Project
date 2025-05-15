// block_gen.v
// 完整7個block配置，平台長度加長，X軸範圍擴大至480
//pla_len at most 15
// 每個障礙物至少間隔50
module block_gen #(
    parameter BLOCK_NUM = 7,
    parameter PLATFORM_NUM_PER_BLOCK = 7,
    parameter PHY_WIDTH = 14,
    parameter BLOCK_WIDTH = 480,
    parameter MAX_JUMP_HEIGHT = 40,
    parameter MAX_JUMP_WIDTH = 50,
    parameter BLOCK_LEN_WIDTH = 4 // max 15
)(
    input sys_clk,
    input sys_rst_n,
    input signed [PHY_WIDTH:0] abs_char_y,
    
    output reg [4:0] camera_y,
    output reg [3:0] cur_block_type,
    output reg [PLATFORM_NUM_PER_BLOCK * PHY_WIDTH-1:0] plat_relative_x,
    output reg [PLATFORM_NUM_PER_BLOCK * PHY_WIDTH-1:0] plat_relative_y,
    output reg [PLATFORM_NUM_PER_BLOCK * BLOCK_LEN_WIDTH-1:0] plat_len,
    output reg block_switch,
    output reg switch_up
);

    reg [4:0] prev_block;
    wire [PHY_WIDTH-1:0] abs_positive_y = (abs_char_y < 0) ? 0 : abs_char_y[PHY_WIDTH-1:0];
    wire [PHY_WIDTH-1:0] block_base_y = (abs_positive_y / BLOCK_WIDTH) * BLOCK_WIDTH;
    wire [4:0] computed_block = block_base_y % BLOCK_NUM; // Be careful with the range of block_num

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            camera_y <= 0;
        end else begin
            camera_y <= abs_positive_y / BLOCK_WIDTH;
        end
    end
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cur_block_type <= 0;
        end else begin
            cur_block_type <= computed_block;
        end
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            prev_block <= 0;
            block_switch <= 0;
            switch_up <= 0;
        end else begin
            block_switch <= (computed_block != prev_block);
            switch_up <= (abs_positive_y >= block_base_y + BLOCK_WIDTH);
            prev_block <= computed_block;
        end
    end

    (* rom_style = "block" *)
    // 完整7個block的硬編碼平台配置
    always @(*) begin

        case (cur_block_type)
            // Block 0: 基礎練習 (寬平台)
            0: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 280; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 60;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 80;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 140; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 200; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 300; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 260; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 150; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 320; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
            end
            
            // Block 1: 左右交替寬跳
            1: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 450; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 10;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 70;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 130; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 190; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 250; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 150; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 310; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 450; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 370; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
            end
            
            // Block 2: 三階式跳躍
            2: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 300; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 15;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 200; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 75;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 135; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 300; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 195; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 200; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 255; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 315; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 300; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 375; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
            end
            
            // Block 3: 右側密集練習
            3: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 20;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 80;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 140; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 200; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 260; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 320; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
            end
            
            // Block 4: 左側密集練習
            4: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 20;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 80;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 140; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 200; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 260; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 320; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
            end
            
            // Block 5: 寬窄交替
            5: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 15;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 75;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 135; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 150; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 195; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 300; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 255; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 200; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 315; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 375; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
            end
            
            // Block 6-18 的配置 (以下為簡化範例，實際需完整補齊)
            6: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 10;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 300; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 70;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 150; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 130; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 190; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 250; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 250; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 310; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 370; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
            end
            default: begin
                // 默認配置 (同block 0)
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 20;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 80;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 140; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 200; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 300; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 260; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 150; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 320; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
            end
        endcase
    end
endmodule