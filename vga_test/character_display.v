module character_display #(
    parameter SIGNED_PHY_WIDTH = 15,
    parameter [2:0] DISPLAY_RATE_WIDTH = 5;
    parameter [DISPLAY_RATE_WIDTH-1:0] REFRESH_RATE = 32
)(
    input sys_clk,
    input sys_rst_n,
    input character_clk,
    input [3:0] char_state,
    input signed [SIGNED_PHY_WIDTH-1:0] vel_y,
    output [3:0] char_display_id
);
localparam [3:0] IDLE = 0, LEFT = 1, RIGHT = 2, CHARGE = 3, JUMP = 4, COLLISION = 5, FALL_TO_GROUND = 6, HOLD = 7;
localparam [3:0] IDLE_DIS_1 = 0, IDLE_DIS_2 = 1, CHARGE_DIS = 2, JUMP_UP_DIS = 3, JUMP_DOWN_DIS = 4, FALL_TO_GROUND_DIS = 5;
localparam [DISPLAY_RATE_WIDTH-1:0] IDLE_BREATHE_TIME = REFRESH_RATE >>> 1; // half second shift
localparam [DISPLAY_RATE_WIDTH-1:0] FALL_TO_GROUND_TIME = REFRESH_RATE; // hold for 1 second

reg character_clk_d;
reg [3:0] char_state_d;
reg signed [SIGNED_PHY_WIDTH-1:0] vel_y_d;
reg [3:0] display_state, next_display_state;
reg [DISPLAY_RATE_WIDTH-1:0] idle_cnt;
reg [DISPLAY_RATE_WIDTH-1:0] fall_cnt;

//--------------------delay--------------------------------
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        character_clk_d <= 0;
        char_state_d <= IDLE;
        vel_y_d <= 0;
    end else begin
        character_clk_d <= character_clk;
        char_state_d <= char_state;
        vel_y_d <= vel_y;
    end
end
//-----------------delay--------------------------------

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
       display_state <= IDLE_DIS;
    end else if (character_clk_d) begin
        display_state <= next_display_state;
    end
end

always @(*) begin
    case (char_state_d)
        IDLE: begin
            if (display_state == FALL_TO_GROUND_DIS && fall_cnt < FALL_TO_GROUND_TIME) begin
                next_display_state = FALL_TO_GROUND_DIS;
            end else if (vel_y_d > 0) begin
                next_display_state = JUMP_UP_DIS;
            end else if (vel_y_d < 0) begin
                next_display_state = JUMP_DOWN_DIS;
            end else begin
                next_display_state = (idle_cnt < IDLE_BREATHE_TIME) ? IDLE_DIS_1 : IDLE_DIS_2;
            end
        end
        CHARGE: begin
            next_display_state = CHARGE_DIS;
        end
        FALL_TO_GROUND: begin
            next_display_state = FALL_TO_GROUND_DIS;
        end
        default: begin
            next_display_state = IDLE_DIS_1;
        end
    endcase
end
assign char_display_id = display_state;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        idle_cnt <= 0;
    end else if (character_clk_d) begin
        idle_cnt <= idle_cnt + 1;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        fall_cnt <= 0;
    end else if (character_clk_d && display_state == FALL_TO_GROUND_DIS) begin
        fall_cnt <= fall_cnt + 1;
    end else begin
        fall_cnt <= 0;
    end
end

endmodule
