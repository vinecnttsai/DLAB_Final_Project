// block_gen.v
// 完整7個block配置，平台長度加長，X軸範圍擴大至480

module block_gen #(
    parameter BLOCK_NUM = 7,
    parameter PLATFORM_NUM_PER_BLOCK = 10,
    parameter PHY_WIDTH = 14,
    parameter BLOCK_WIDTH = 480,
    parameter MAX_JUMP_HEIGHT = 40,
    parameter MAX_JUMP_WIDTH = 50
)(
    input clk,
    input rst_n,
    input [PHY_WIDTH-1:0] abs_char_y,
    
    output reg [4:0] camera,
    output reg [3:0] cur_block,
    output reg [PLATFORM_NUM_PER_BLOCK-1:0][PHY_WIDTH-1:0] plat_x,
    output reg [PLATFORM_NUM_PER_BLOCK-1:0][PHY_WIDTH-1:0] plat_y,
    output reg [PLATFORM_NUM_PER_BLOCK-1:0][PHY_WIDTH-1:0] plat_len,
    output reg block_switch,
    output reg switch_up
);

    reg [4:0] prev_block;
    wire [PHY_WIDTH-1:0] block_base_y = (abs_char_y / BLOCK_WIDTH) * BLOCK_WIDTH;
    wire [4:0] computed_block = block_base_y % BLOCK_NUM;
    
    always @(posedge clk or negedge rst_n) begin
        camera <= abs_char_y / BLOCK_WIDTH;
        if (!rst_n) begin
            cur_block <= 0;
        end else begin
            cur_block <= computed_block;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_block <= 0;
            block_switch <= 0;
            switch_up <= 0;
        end else begin
            block_switch <= (computed_block != prev_block);
            switch_up <= (abs_char_y >= block_base_y + BLOCK_WIDTH);
            prev_block <= computed_block;
        end
    end

    (* rom_style = "block" *)
    // 完整19個block的硬編碼平台配置
    always @(*) begin

        case (cur_block)
            // Block 0: 基礎練習 (寬平台)
            0: begin
                plat_x[0] = 400; plat_y[0] = 20;  plat_len[0] = 8;
                plat_x[1] = 100; plat_y[1] = 80;  plat_len[1] = 8;
                plat_x[2] = 350; plat_y[2] = 140; plat_len[2] = 8;
                plat_x[3] = 50;  plat_y[3] = 200; plat_len[3] = 8;
                plat_x[4] = 300; plat_y[4] = 260; plat_len[4] = 8;
                plat_x[5] = 150; plat_y[5] = 320; plat_len[5] = 8;
                plat_x[6] = 400; plat_y[6] = 380; plat_len[6] = 8;
                plat_x[7] = 200; plat_y[7] = 420; plat_len[7] = 8;
                plat_x[8] = 50;  plat_y[8] = 450; plat_len[8] = 8;
                plat_x[9] = 300; plat_y[9] = 470; plat_len[9] = 8;
            end
            
            // Block 1: 左右交替寬跳
            1: begin
                plat_x[0] = 450; plat_y[0] = 10;  plat_len[0] = 5;
                plat_x[1] = 50;  plat_y[1] = 70;  plat_len[1] = 5;
                plat_x[2] = 400; plat_y[2] = 130; plat_len[2] = 5;
                plat_x[3] = 100; plat_y[3] = 190; plat_len[3] = 5;
                plat_x[4] = 350; plat_y[4] = 250; plat_len[4] = 5;
                plat_x[5] = 150; plat_y[5] = 310; plat_len[5] = 5;
                plat_x[6] = 450; plat_y[6] = 370; plat_len[6] = 5;
                plat_x[7] = 200; plat_y[7] = 410; plat_len[7] = 5;
                plat_x[8] = 50;  plat_y[8] = 445; plat_len[8] = 5;
                plat_x[9] = 350; plat_y[9] = 475; plat_len[9] = 5;
            end
            
            // Block 2: 三階式跳躍
            2: begin
                plat_x[0] = 300; plat_y[0] = 15;  plat_len[0] = 60;
                plat_x[1] = 200; plat_y[1] = 75;  plat_len[1] = 60;
                plat_x[2] = 100; plat_y[2] = 135; plat_len[2] = 60;
                plat_x[3] = 300; plat_y[3] = 195; plat_len[3] = 60;
                plat_x[4] = 200; plat_y[4] = 255; plat_len[4] = 60;
                plat_x[5] = 100; plat_y[5] = 315; plat_len[5] = 60;
                plat_x[6] = 300; plat_y[6] = 375; plat_len[6] = 60;
                plat_x[7] = 200; plat_y[7] = 415; plat_len[7] = 60;
                plat_x[8] = 100; plat_y[8] = 455; plat_len[8] = 60;
                plat_x[9] = 300; plat_y[9] = 475; plat_len[9] = 60;
            end
            
            // Block 3: 右側密集練習
            3: begin
                plat_x[0] = 400; plat_y[0] = 20;  plat_len[0] = 80;
                plat_x[1] = 350; plat_y[1] = 80;  plat_len[1] = 80;
                plat_x[2] = 400; plat_y[2] = 140; plat_len[2] = 80;
                plat_x[3] = 350; plat_y[3] = 200; plat_len[3] = 80;
                plat_x[4] = 400; plat_y[4] = 260; plat_len[4] = 80;
                plat_x[5] = 350; plat_y[5] = 320; plat_len[5] = 80;
                plat_x[6] = 400; plat_y[6] = 380; plat_len[6] = 80;
                plat_x[7] = 350; plat_y[7] = 420; plat_len[7] = 80;
                plat_x[8] = 400; plat_y[8] = 450; plat_len[8] = 80;
                plat_x[9] = 350; plat_y[9] = 470; plat_len[9] = 80;
            end
            
            // Block 4: 左側密集練習
            4: begin
                plat_x[0] = 50;  plat_y[0] = 20;  plat_len[0] = 80;
                plat_x[1] = 100; plat_y[1] = 80;  plat_len[1] = 80;
                plat_x[2] = 50;  plat_y[2] = 140; plat_len[2] = 80;
                plat_x[3] = 100; plat_y[3] = 200; plat_len[3] = 80;
                plat_x[4] = 50;  plat_y[4] = 260; plat_len[4] = 80;
                plat_x[5] = 100; plat_y[5] = 320; plat_len[5] = 80;
                plat_x[6] = 50;  plat_y[6] = 380; plat_len[6] = 80;
                plat_x[7] = 100; plat_y[7] = 420; plat_len[7] = 80;
                plat_x[8] = 50;  plat_y[8] = 450; plat_len[8] = 80;
                plat_x[9] = 100; plat_y[9] = 470; plat_len[9] = 80;
            end
            
            // Block 5: 寬窄交替
            5: begin
                plat_x[0] = 400; plat_y[0] = 15;  plat_len[0] = 80;
                plat_x[1] = 100; plat_y[1] = 75;  plat_len[1] = 40;
                plat_x[2] = 350; plat_y[2] = 135; plat_len[2] = 80;
                plat_x[3] = 150; plat_y[3] = 195; plat_len[3] = 40;
                plat_x[4] = 300; plat_y[4] = 255; plat_len[4] = 80;
                plat_x[5] = 200; plat_y[5] = 315; plat_len[5] = 40;
                plat_x[6] = 400; plat_y[6] = 375; plat_len[6] = 80;
                plat_x[7] = 250; plat_y[7] = 415; plat_len[7] = 40;
                plat_x[8] = 50;  plat_y[8] = 455; plat_len[8] = 80;
                plat_x[9] = 300; plat_y[9] = 475; plat_len[9] = 40;
            end
            
            // Block 6-18 的配置 (以下為簡化範例，實際需完整補齊)
            6: begin
                plat_x[0] = 50;  plat_y[0] = 10;  plat_len[0] = 100;
                plat_x[1] = 300; plat_y[1] = 70;  plat_len[1] = 100;
                plat_x[2] = 150; plat_y[2] = 130; plat_len[2] = 100;
                plat_x[3] = 400; plat_y[3] = 190; plat_len[3] = 100;
                plat_x[4] = 250; plat_y[4] = 250; plat_len[4] = 100;
                plat_x[5] = 100; plat_y[5] = 310; plat_len[5] = 100;
                plat_x[6] = 350; plat_y[6] = 370; plat_len[6] = 100;
                plat_x[7] = 200; plat_y[7] = 410; plat_len[7] = 100;
                plat_x[8] = 50;  plat_y[8] = 450; plat_len[8] = 100;
                plat_x[9] = 300; plat_y[9] = 470; plat_len[9] = 100;
            end
            default: begin
                // 默認配置 (同block 0)
                plat_x[0] = 400; plat_y[0] = 20;  plat_len[0] = 80;
                plat_x[1] = 100; plat_y[1] = 80;  plat_len[1] = 80;
                plat_x[2] = 350; plat_y[2] = 140; plat_len[2] = 80;
                plat_x[3] = 50;  plat_y[3] = 200; plat_len[3] = 80;
                plat_x[4] = 300; plat_y[4] = 260; plat_len[4] = 80;
                plat_x[5] = 150; plat_y[5] = 320; plat_len[5] = 80;
                plat_x[6] = 400; plat_y[6] = 380; plat_len[6] = 80;
                plat_x[7] = 200; plat_y[7] = 420; plat_len[7] = 80;
                plat_x[8] = 50;  plat_y[8] = 450; plat_len[8] = 80;
                plat_x[9] = 300; plat_y[9] = 470; plat_len[9] = 80;
            end
        endcase
    end
endmodule