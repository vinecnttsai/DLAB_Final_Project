module tb_character #(
    parameter PHY_WIDTH = 10,
    parameter MAP_WIDTH_X = 100,
    parameter MAP_WIDTH_Y = 100,
    parameter PIXEL_WIDTH = 12,
    parameter CHAR_WIDTH_X = 32,
    parameter CHAR_WIDTH_Y = 32,
    parameter INITIAL_POS_X = 0,
    parameter INITIAL_POS_Y = BOTTOM_WALL + WALL_WIDTH + 1,
    parameter LEFT_WALL = MAP_WIDTH_X - WALL_WIDTH,
    parameter RIGHT_WALL = 0,
    parameter TOP_WALL = MAP_WIDTH_Y - WALL_WIDTH,
    parameter BOTTOM_WALL = 0,
    parameter WALL_WIDTH = 10 ) (
    input character_clk,
    input sys_rst_n,
    input left_btn,
    input right_btn,
    input jump_btn,
    output [PHY_WIDTH:0] out_pos_x,
    output [PHY_WIDTH:0] out_pos_y,
    output [PHY_WIDTH:0] out_vel_x,
    output [PHY_WIDTH:0] out_vel_y,
    output [PHY_WIDTH:0] out_acc_x,
    output [PHY_WIDTH:0] out_acc_y,
    output [1:0] out_face,
    output [7:0] out_jump_cnt,
    output [3:0] out_state,
    output [2:0] out_collision_type,
    output [1:0] out_fall_to_ground,
    output [1:0] out_on_ground
);
// output wire
assign out_pos_x = pos_x_reg;
assign out_pos_y = pos_y_reg;
assign out_vel_x = vel_x_reg;
assign out_vel_y = vel_y_reg;
assign out_acc_x = acc_x_reg;
assign out_acc_y = acc_y_reg;
assign out_face = face;
assign out_jump_cnt = {1'b0, jump_cnt};
assign out_state = {1'b0, state};
assign out_collision_type = {1'b0, collision_type};
assign out_fall_to_ground = {1'b0, fall_to_ground};
assign out_on_ground = {1'b0, on_ground};


// FSM variables
localparam [2:0] IDLE = 0, LEFT = 1, RIGHT = 2, CHARGE = 3, JUMP = 4, COLLISION = 5, FALL_TO_GROUND = 6;
reg [2:0] state, next_state;

// physics simulation
localparam GRAVITY = 1;
localparam POSITIVE = GRAVITY;
localparam LEFT_VEL_X = 1;
localparam RIGHT_VEL_X = 1;
localparam JUMP_VEL_X = 4;
localparam JUMP_VEL_Y = 8;

reg signed [PHY_WIDTH:0] acc_x_reg, acc_y_reg; // 11-bit signed integer
reg signed [PHY_WIDTH:0] vel_x_reg, vel_y_reg;
reg signed [PHY_WIDTH:0] pos_x_reg, pos_y_reg;
reg signed [PHY_WIDTH:0] acc_x, acc_y;
reg signed [PHY_WIDTH:0] vel_x, vel_y;
reg signed [PHY_WIDTH:0] pos_x, pos_y;

// 0: no face, 1: face left, -1: face right
reg signed [1:0] face;

// jump cnt
localparam MAX_CHARGE = 100;
localparam JUMP_INCREMENT = 10;
reg [6:0] jump_cnt;
wire max_charge;

// collision type
localparam FALLING_VEL_THRESHOLD = 15;
wire [1:0] collision_type; // 0: no collision, 1: collision horizontal, 2: collision vertical
wire fall_to_ground;
wire on_ground;
assign collision_type = detect_collision(pos_x_reg, pos_y_reg);
assign fall_to_ground = detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg);
assign on_ground = detect_on_ground(pos_x_reg, pos_y_reg);

// button edge detection
wire left_btn_posedge, right_btn_posedge, jump_btn_posedge;
reg left_btn_d, right_btn_d, jump_btn_d;

always @(posedge character_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        left_btn_d <= 0;
        right_btn_d <= 0;
        jump_btn_d <= 0;
    end else begin
        left_btn_d <= left_btn;
        right_btn_d <= right_btn;
        jump_btn_d <= jump_btn;
    end
end
assign left_btn_posedge = ~left_btn_d && left_btn;
assign right_btn_posedge = ~right_btn_d && right_btn;
assign jump_btn_posedge = ~jump_btn_d && jump_btn;


//-----------------------------------------FSM-----------------------------------------
always @(posedge character_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    case (state)
        IDLE, LEFT, RIGHT: begin
            if (fall_to_ground) begin
                next_state = FALL_TO_GROUND;
            end else if (collision_type > 0) begin
                next_state = COLLISION;
            end else if (left_btn_posedge) begin
                next_state = LEFT;
            end else if (right_btn_posedge) begin
                next_state = RIGHT;
            end else if (jump_btn_posedge) begin
                next_state = CHARGE;
            end else begin 
                next_state = IDLE;
            end
        end
        CHARGE: begin
            if (fall_to_ground) begin
                next_state = FALL_TO_GROUND;
            end else if (collision_type > 0) begin
                next_state = COLLISION;
            end else if (max_charge || ~jump_btn) begin
                next_state = JUMP;
            end else begin
                next_state = CHARGE;
            end
        end
        JUMP, FALL_TO_GROUND, COLLISION: begin
            if (fall_to_ground) begin
                next_state = FALL_TO_GROUND;
            end else if (collision_type > 0) begin
                next_state = COLLISION;
            end else begin
                next_state = IDLE;
            end
        end
        default: begin
            if (fall_to_ground) begin
                next_state = FALL_TO_GROUND;
            end else if (collision_type > 0) begin
                next_state = COLLISION;
            end else begin
                next_state = IDLE;
            end
        end
    endcase
end
assign max_charge = (state == CHARGE) && (jump_cnt >= MAX_CHARGE);
//-----------------------------------------FSM-----------------------------------------



//-----------------------------------------Character Movement-----------------------------------------
always @(posedge character_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        jump_cnt <= 1;
    end else begin
        if (state == CHARGE) begin
            jump_cnt <= jump_cnt + JUMP_INCREMENT;
        end else if (state == JUMP) begin
            jump_cnt <= 1;
        end
    end
end

always @(posedge character_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        face <= 1;
    end else if (collision_type == 2) begin
        face <= -face;
    end else if (state == LEFT) begin
        face <= 1;
    end else if (state == RIGHT) begin
        face <= -1;
    end
end

always @(*) begin
    if (on_ground) begin
        acc_x = 0;
        acc_y = 0;
    end else begin
        acc_x = 0;
        acc_y = -GRAVITY;
    end
end

always @(*) begin
    if (fall_to_ground) begin
        vel_x = -vel_x_reg;
        vel_y = -vel_y_reg;
    end else if (collision_type == 1) begin
        vel_x = 0;
        vel_y = -2 * vel_y_reg;
    end else if (collision_type == 2) begin
        vel_x = -2 * vel_x_reg;
        vel_y = 0;
    end else if (state == CHARGE && (max_charge || !jump_btn)) begin
        vel_x = JUMP_VEL_X * $clog2(jump_cnt) * face;
        vel_y = JUMP_VEL_Y * $clog2(jump_cnt);
    end
end

always @(*) begin
    if (fall_to_ground) begin
        {pos_x, pos_y} = calculate_impact_pos(pos_x_reg, pos_y_reg, vel_x_reg, vel_y_reg);
    end else if (left_btn_posedge) begin
        pos_x = LEFT_VEL_X;
        pos_y = 0;
    end else if (right_btn_posedge) begin
        pos_x = -RIGHT_VEL_X;
        pos_y = 0;
    end else begin
        pos_x = 0;
        pos_y = 0;
    end
end

// ???|?�Z?
always @(posedge character_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        acc_x_reg <= 0;
        acc_y_reg <= 0;
    end else begin
        acc_x_reg <= acc_x_reg + acc_x;
        acc_y_reg <= acc_y_reg + acc_y;
    end
end

always @(posedge character_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        vel_x_reg <= 0;
        vel_y_reg <= 0;
    end else begin
        vel_x_reg <= (vel_x_reg + vel_x) + (acc_x);
        vel_y_reg <= (vel_y_reg + vel_y) + (acc_y);
    end
end

always @(posedge character_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        pos_x_reg <= INITIAL_POS_X;
        pos_y_reg <= INITIAL_POS_Y;
    end else begin
        pos_x_reg <= (pos_x_reg + pos_x) + (vel_x_reg + vel_x);
        pos_y_reg <= (pos_y_reg + pos_y) + (vel_y_reg + vel_y);
    end
end
//-----------------------------------------Character Movement-----------------------------------------


//-----------------------------------------detect boundary-----------------------------------------
// character outer frame
// -----------------------
// |                     |
// |                     |
// |                     |
// |                     |
// |                     |
// |                     |
// -----------------------
wire [CHAR_WIDTH_X-1:0] top_row_frame;
wire [CHAR_WIDTH_X-1:0] bottom_row_frame; //collumn detection
wire [CHAR_WIDTH_Y-1:0] left_col_frame;
wire [CHAR_WIDTH_Y-1:0] right_col_frame; //row detection

integer i;
generate
    for (i = 0; i < CHAR_WIDTH_X; i = i + 1) begin
        assign top_row_frame[i] = (i < LEFT_WALL || i >= RIGHT_WALL + WALL_WIDTH);
        assign bottom_row_frame[i] = (i < LEFT_WALL || i >= RIGHT_WALL + WALL_WIDTH);
    end
    for (i = 0; i < CHAR_WIDTH_Y; i = i + 1) begin
        assign left_col_frame[i] = (i < TOP_WALL || i >= BOTTOM_WALL + WALL_WIDTH);
        assign right_col_frame[i] = (i < TOP_WALL || i >= BOTTOM_WALL + WALL_WIDTH);
    end
endgenerate


function detect_row_boundary;
    input [$clog2(CHAR_WIDTH_Y + 1)-1:0] row;
    begin
        detect_row_boundary = left_col_frame[row] && right_col_frame[row];
    end
endfunction

function detect_col_boundary;
    input [$clog2(CHAR_WIDTH_X + 1)-1:0] col;
    begin
        detect_col_boundary = top_row_frame[col] && bottom_row_frame[col];
    end
endfunction

//-----------------------------------------detect boundary-----------------------------------------

//-----------------------------------------Push Character to the Ground-----------------------------------------
function signed [PHY_WIDTH:0] calculate_impact_pos;
    input signed [PHY_WIDTH:0] pos_x_reg;
    input signed [PHY_WIDTH:0] pos_y_reg;
    input signed [PHY_WIDTH:0] vel_x_reg;
    input signed [PHY_WIDTH:0] vel_y_reg;
    integer i;

    reg signed [PHY_WIDTH:0] distance_to_ground;
    reg enable;
    begin
        enable = 1;
        distance_to_ground = 0;
        if (detect_row_boundary(pos_y_reg)) begin
            for (i = pos_y_reg + 1; i < MAP_WIDTH_Y; i = i + 1) begin
                if (!detect_row_boundary(i)) begin
                    distance_to_ground = i - pos_y_reg + WALL_WIDTH;
                    enable = 0;
                end else begin
                    distance_to_ground = distance_to_ground;
                end
            end
        end else begin
            for (i = pos_y_reg + 1; i < MAP_WIDTH_Y; i = i + 1) begin
                if (detect_row_boundary(i)) begin
                    distance_to_ground = i - pos_y_reg;
                    enable = 0;
                end else begin
                    distance_to_ground = distance_to_ground;
                end
            end
        end

        calculate_impact_pos = {-(vel_x_reg * distance_to_ground) / vel_y_reg, distance_to_ground};
    end
endfunction
//-----------------------------------------Push Character to the Ground-----------------------------------------


//-----------------------------------------Character Detection-----------------------------------------
// detect_collision  = 1
//--------------
//     -
//    - -
//   -   -
//  -     -
// -       -
// detect_collision  = 2
// |        |  
// |      |
// |    |
// |  |
// |    |
// |      |
// |         | 
function [1:0] detect_collision;
    input signed [PHY_WIDTH:0] pos_x_reg;
    input signed [PHY_WIDTH:0] pos_y_reg;
    integer i;

    reg [1:0] row_detection; // 0: no detect, 1: detect once, 2: detect twice
    reg [1:0] col_detection; // 0: no detect, 1: detect once, 2: detect twice
    begin
        for (i = 0; i < CHAR_WIDTH_Y; i = i + 1) begin
            if (row_detection >= 1) begin
                row_detection = 1;
            end else if (!detect_row_boundary(i)) begin
                row_detection = 1;
            end else begin
                row_detection = 0;
            end
        end

        for (i = 0; i < CHAR_WIDTH_X; i = i + 1) begin
            if (col_detection >= 1) begin
                col_detection = 1;
            end else if (!detect_col_boundary(i)) begin
                col_detection = 1;
            end else begin
                col_detection = 0;
            end
        end

        if (row_detection >= 1) begin
            detect_collision = 1; // higher priority
        end else if (col_detection >= 1) begin
            detect_collision = 2;
        end else begin
            detect_collision = 0;
        end
    end
endfunction

function detect_fall_to_ground;
    input signed [PHY_WIDTH:0] pos_x_reg;
    input signed [PHY_WIDTH:0] pos_y_reg;
    input signed [PHY_WIDTH:0] vel_y_reg;
    begin
        detect_fall_to_ground = (collision_type == 1) && (vel_y_reg < 0);
    end
endfunction

function detect_on_ground;
    input signed [PHY_WIDTH:0] pos_x_reg;
    input signed [PHY_WIDTH:0] pos_y_reg;
    begin
        detect_on_ground =  (detect_row_boundary(pos_y_reg) && !detect_row_boundary(pos_y_reg - 1));
    end
endfunction
//-----------------------------------------Character Detection-----------------------------------------




//-----------------------------------------Character Display-----------------------------------------

//-----------------------------------------Character Display-----------------------------------------

endmodule