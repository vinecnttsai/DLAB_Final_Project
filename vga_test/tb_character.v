module tb_character #(
    parameter MAP_X = 100,
    parameter MAP_Y = 100,
    parameter PIXEL_WIDTH = 12,
    parameter CHAR_WIDTH_X = 16,
    parameter CHAR_WIDTH_Y = 16,
    parameter GROUND_POS_Y = 0,
    parameter LEFT_WALL = 0,
    parameter RIGHT_WALL = 0,
    parameter TOP_WALL = 0,
    parameter BOTTOM_WALL = 0 ) (
    input character_clk,
    input sys_rst_n,
    input left_btn,
    input right_btn,
    input jump_btn,
    output [9:0] out_pos_x,
    output [9:0] out_pos_y,
    output [9:0] out_vel_x,
    output [9:0] out_vel_y,
    output [9:0] out_acc_x,
    output [9:0] out_acc_y,
    output [9:0] out_jump_cnt,
    output [1:0] out_face,
    output [2:0] out_state,
    output [1:0] out_collision_type,
    output out_fall_to_ground,
    output out_on_ground
);
// output wire
assign out_pos_x = pos_x_reg;
assign out_pos_y = pos_y_reg;
assign out_vel_x = vel_x_reg;
assign out_vel_y = vel_y_reg;
assign out_acc_x = acc_x_reg;
assign out_acc_y = acc_y_reg;
assign out_jump_cnt = jump_cnt;
assign out_face = face;
assign out_state = state;
assign out_collision_type = collision_type;
assign out_fall_to_ground = fall_to_ground;
assign out_on_ground = on_ground;


// FSM variables
localparam [2:0] IDLE = 0, LEFT = 1, RIGHT = 2, CHARGE = 3, JUMP = 4, COLLISION = 5, FALL_TO_GROUND = 6;
reg [2:0] state, next_state;

// physics simulation
localparam PHY_WIDTH = 10;
localparam [PHY_WIDTH-1:0] GRAVITY = 1;
localparam [PHY_WIDTH-1:0] POSITIVE = GRAVITY;
localparam [PHY_WIDTH-1:0] LEFT_VEL_X = 1;
localparam [PHY_WIDTH-1:0] RIGHT_VEL_X = 1;
localparam [PHY_WIDTH-1:0] JUMP_VEL_X = 4;
localparam [PHY_WIDTH-1:0] JUMP_VEL_Y = 8;
localparam [PHY_WIDTH-1:0] INITIAL_POS_X = (MAP_X - CHAR_WIDTH_X) / 2;
localparam [PHY_WIDTH-1:0] INITIAL_POS_Y = GROUND_POS_Y + 1;

reg [PHY_WIDTH-1:0] acc_x_reg, acc_y_reg; // unused
reg [PHY_WIDTH-1:0] vel_x_reg, vel_y_reg;
reg [PHY_WIDTH-1:0] pos_x_reg, pos_y_reg;
reg [PHY_WIDTH-1:0] acc_x, acc_y;
reg [PHY_WIDTH-1:0] vel_x, vel_y;
reg [PHY_WIDTH-1:0] pos_x, pos_y;

// 0: no face, 1: face left, -1: face right
localparam [1:0] FACE_LEFT = 1;
localparam [1:0] FACE_RIGHT = -1;
reg [1:0] face;

// jump cnt
localparam [PHY_WIDTH-1:0] MAX_CHARGE = 100;
localparam [PHY_WIDTH-1:0] JUMP_INCREMENT = 10;
reg [$clog2(MAX_CHARGE + 1)-1:0] jump_cnt;
wire max_charge;

// collision type
localparam [PHY_WIDTH-1:0] FALLING_VEL_THRESHOLD = 15;
wire [1:0] collision_type; // 0: no collision, 1: collision horizontal, 2: collision vertical
wire fall_to_ground;
wire on_ground;
assign collision_type = detect_collision(pos_x_reg, pos_y_reg, map);
assign fall_to_ground = detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg, map);
assign on_ground = detect_on_ground(pos_x_reg, pos_y_reg, map);

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


//-----------------------------------------Utilities-----------------------------------------
function [PIXEL_WIDTH-1:0] map_data;
    input [PHY_WIDTH-1:0] x_pos;
    input [PHY_WIDTH-1:0] y_pos;
    input [MAP_X * MAP_Y * PIXEL_WIDTH-1:0] map;
    begin
        map_data = map[(y_pos * MAP_X + x_pos) * PIXEL_WIDTH +: PIXEL_WIDTH];
    end
endfunction

function [PHY_WIDTH-1:0] double_division_mutiplication;
    input [PHY_WIDTH-1:0] dividend;
    input [PHY_WIDTH-1:0] divisor;
    input [PHY_WIDTH-1:0] scalar;
    begin
        double_division_mutiplication = dividend * scalar / divisor;
    end
endfunction
//-----------------------------------------Utilities-----------------------------------------


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
        IDLE, LEFT, RIGHT: begin // ??n???n?? prority_decoder
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
//?????D?Afall to ground??|?^????
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
        face <= FACE_LEFT;
    end else if (collision_type == 2) begin
        face <= -1 * face;
    end else if (state == LEFT) begin
        face <= FACE_LEFT;
    end else if (state == RIGHT) begin
        face <= FACE_RIGHT;
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
        {pos_x, pos_y} = calculate_impact_pos(pos_x_reg, pos_y_reg, vel_x_reg, vel_y_reg, map);
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


//-----------------------------------------Push Character to the Ground-----------------------------------------
function [PHY_WIDTH + PHY_WIDTH-1:0] calculate_impact_pos;
    input [PHY_WIDTH-1:0] pos_x_reg;
    input [PHY_WIDTH-1:0] pos_y_reg;
    input [PHY_WIDTH-1:0] vel_x_reg;
    input [PHY_WIDTH-1:0] vel_y_reg;
    input [MAP_X * MAP_Y * PIXEL_WIDTH-1:0] map;
    integer i;

    reg distance_to_ground;
    begin
        for (i = pos_y_reg + 1; i < MAP_Y; i = i + 1) begin
            if (map_data(pos_x_reg, i, map) == MOVABLE_PIXEL_ID) begin
                distance_to_ground = i - pos_y_reg;
            end
        end

        calculate_impact_pos = {-1 * (vel_x_reg * distance_to_ground) / vel_y_reg, distance_to_ground};
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
function [1:0] detect_collision; // ?|???y????HCharacter pixel
    input [PHY_WIDTH-1:0] pos_x_reg;
    input [PHY_WIDTH-1:0] pos_y_reg;
    input [MAP_X * MAP_Y * PIXEL_WIDTH-1:0] map;
    integer i, k;

    reg [1:0] row_detection; // 0: no detect, 1: detect once, 2: detect twice
    reg [1:0] col_detection; // 0: no detect, 1: detect once, 2: detect twice
    begin
        for (i = 0; i < CHAR_WIDTH_Y; i = i + 1) begin
            if (row_detection >= 1) begin
                row_detection = 1;
            end else if (map_data(pos_x_reg, pos_y_reg + i, map) == OBSTACLE_PIXEL_ID && map_data(pos_x_reg + CHAR_WIDTH_X - 1, pos_y_reg + i, map) == OBSTACLE_PIXEL_ID) begin
                row_detection = 1;
            end else begin
                row_detection = 0;
            end
        end

        for (i = 0; i < CHAR_WIDTH_X; i = i + 1) begin
            if (col_detection >= 1) begin
                col_detection = 1;
            end else if (map_data(pos_x_reg + i, pos_y_reg, map) == OBSTACLE_PIXEL_ID && map_data(pos_x_reg + i, pos_y_reg + CHAR_WIDTH_Y - 1, map) == OBSTACLE_PIXEL_ID) begin
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
    input [PHY_WIDTH-1:0] pos_x_reg;
    input [PHY_WIDTH-1:0] pos_y_reg;
    input [PHY_WIDTH-1:0] vel_y_reg;
    input [MAP_X * MAP_Y * PIXEL_WIDTH-1:0] map;
    integer i;
    begin
        detect_fall_to_ground = (collision_type == 1) && (vel_y_reg < 0);
    end
endfunction

function detect_on_ground;
    input [PHY_WIDTH-1:0] pos_x_reg;
    input [PHY_WIDTH-1:0] pos_y_reg;
    input [MAP_X * MAP_Y * PIXEL_WIDTH-1:0] map;
    integer i;
    begin
        detect_on_ground =  (map_data(pos_x_reg, pos_y_reg, map) == MOVABLE_PIXEL_ID && map_data(pos_x_reg + CHAR_WIDTH_X - 1, pos_y_reg, map) == MOVABLE_PIXEL_ID) &&
                            (map_data(pos_x_reg, pos_y_reg - 1, map) == OBSTACLE_PIXEL_ID && map_data(pos_x_reg + CHAR_WIDTH_X - 1, pos_y_reg - 1, map) == OBSTACLE_PIXEL_ID);
    end
endfunction
//-----------------------------------------Character Detection-----------------------------------------




//-----------------------------------------Character Display-----------------------------------------

//-----------------------------------------Character Display-----------------------------------------

endmodule