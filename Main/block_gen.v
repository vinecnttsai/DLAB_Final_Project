module block_gen #(
    parameter BLOCK_NUM = 7,
    parameter PLATFORM_NUM_PER_BLOCK = 7,
    parameter PHY_WIDTH = 16,
    parameter CAMERA_WIDTH = 6,
    parameter BLOCK_WIDTH = 480,
    parameter MAX_JUMP_HEIGHT = 40,
    parameter MAX_JUMP_WIDTH = 50,
    parameter BLOCK_LEN_WIDTH = 4 // max 15
)(
    input sys_clk,
    input sys_rst_n,
    input signed [PHY_WIDTH:0] abs_camera_y,
    
    output reg [CAMERA_WIDTH - 1:0] camera_y,
    output reg [3:0] cur_block_type,
    output reg [PLATFORM_NUM_PER_BLOCK * PHY_WIDTH-1:0] plat_relative_x,
    output reg [PLATFORM_NUM_PER_BLOCK * PHY_WIDTH-1:0] plat_relative_y,
    output reg [PLATFORM_NUM_PER_BLOCK * BLOCK_LEN_WIDTH-1:0] plat_len,
    output reg block_switch,
    output reg switch_up
);

    reg [4:0] prev_block;
    wire [PHY_WIDTH-1:0] abs_positive_y = (abs_camera_y < 0) ? 0 : abs_camera_y[PHY_WIDTH-1:0];
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
    always @(*) begin

        case (cur_block_type)
            0: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 280; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 35;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 100; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 100;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 370; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 150; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 30;  plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 250; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 250; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 280; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 120; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 8;
            end
            
            1: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 300; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 30;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 120;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 13;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 380; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 130; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 90; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 260; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 320; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 260; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 150; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 400; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 13;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 10;   plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 370; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
            end
            
            2: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 260; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 30;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 12;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 120; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 75;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 10; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 135; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 250; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 195; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 120; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 255; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 10; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 350; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 180; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 375; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 13;
            end
            
            3: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 20;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 70; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 30;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 280; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 160; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 4;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 140; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 140; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 200; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 280; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 4;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 250; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 360; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 120; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 6;
            end
            
            4: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 240; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 20;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 70;  plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 130; plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 340; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 170; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 10;   plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 250; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 4;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 270; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 3;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 440; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 360; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 4;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 160; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 370; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 13;
            end
            
            5: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 230; plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 30;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 7;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 10; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 7;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 160; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 150; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 180; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 220; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 245; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 130; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 5;
            end
            
            6: begin
                plat_relative_x[0*PHY_WIDTH +: PHY_WIDTH] = 50;  plat_relative_y[0*PHY_WIDTH +: PHY_WIDTH] = 20;  plat_len[0*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[1*PHY_WIDTH +: PHY_WIDTH] = 300; plat_relative_y[1*PHY_WIDTH +: PHY_WIDTH] = 40;  plat_len[1*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[2*PHY_WIDTH +: PHY_WIDTH] = 130; plat_relative_y[2*PHY_WIDTH +: PHY_WIDTH] = 130; plat_len[2*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 4;
                plat_relative_x[3*PHY_WIDTH +: PHY_WIDTH] = 400; plat_relative_y[3*PHY_WIDTH +: PHY_WIDTH] = 180; plat_len[3*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[4*PHY_WIDTH +: PHY_WIDTH] = 220; plat_relative_y[4*PHY_WIDTH +: PHY_WIDTH] = 250; plat_len[4*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[5*PHY_WIDTH +: PHY_WIDTH] = 60; plat_relative_y[5*PHY_WIDTH +: PHY_WIDTH] = 350; plat_len[5*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
                plat_relative_x[6*PHY_WIDTH +: PHY_WIDTH] = 350; plat_relative_y[6*PHY_WIDTH +: PHY_WIDTH] = 380; plat_len[6*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] = 10;
            end
            default: begin
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