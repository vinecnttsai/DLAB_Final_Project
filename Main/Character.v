//完成角色的位置更新、pixel更新
//注意是WIDTH, 婦好放在reg裡面會不會出問題
//還沒有bounadry check
//map data有點問題, 是要有pixel width還是不要
// 假設地圖是 3 * 6，則排列方式會像下面
module Chraracter #(parameter MAP_X = 640,
                    parameter MAP_Y = 480,
                    parameter MAP_X_WIDTH = $clog2(MAP_X + 1),
                    parameter MAP_Y_WIDTH = $clog2(MAP_Y + 1),
                    parameter PIXEL_WIDTH = 16,
                    parameter CHAR_WIDTH_X = 4, // 
                    parameter CHAR_WIDTH_Y = 3, // 要改
                    parameter MOVABLE_PIXEL_ID = 0,
                    parameter OBSTACLE_PIXEL_ID = 1,
                    parameter GROUND_POS_Y = 0 ) (
    input character_clk,
    input sys_rst_n,
    input left_btn,
    input right_btn,
    input jump_btn, // 注意btn要不要讓他穩定一點, 加個shift reg
    input [MAP_X_WIDTH-1:0] x_pos,
    input [MAP_Y_WIDTH-1:0] y_pos,
    input [MAP_X * MAP_Y * PIXEL_WIDTH - 1:0] map,
    output reg [CHAR_WIDTH_X * CHAR_WIDTH_Y * PIXEL_WIDTH - 1:0] char_pixel,
);
// FSM variables
localparam [2:0] IDLE = 0, LEFT = 1, RIGHT = 2, CHARGE = 3, JUMP = 4, COLLISION = 5, FALL_TO_GROUND = 6;
reg [2:0] state, next_state;

// physics simulation
localparam PHY_WIDTH = MAP_X_WIDTH; // 應該是 max(x_width, y_width)
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
assign collision_type = detect_collision(pos_x_reg, pos_y_reg, map);

// button debounce
localparam DEBOUNCE_TIME = 100;
localparam DEBOUNCE_FREQUENCY = 1000;
wire left_btn_debounce, right_btn_debounce, jump_btn_debounce;
// button reg
wire left_btn_posedge, right_btn_posedge, jump_btn_posedge;
wire jump_btn_negedge;
reg left_btn_reg, right_btn_reg, jump_btn_reg;



//-----------------------------------------Debounce button--------------------------------------
always @(posedge character_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        left_btn_reg <= 0;
        right_btn_reg <= 0;
        jump_btn_reg <= 0;
    end else begin
        left_btn_reg <= left_btn_debounce;
        right_btn_reg <= right_btn_debounce;
        jump_btn_reg <= jump_btn_debounce;
    end
end
assign left_btn_posedge = !left_btn_reg && left_btn_debounce;
assign right_btn_posedge = !right_btn_reg && right_btn_debounce;
assign jump_btn_posedge = !jump_btn_reg && jump_btn_debounce;
assign jump_btn_negedge = jump_btn_reg && !jump_btn_debounce;
//-----------------------------------------Debounce button--------------------------------------


//-----------------------------------------Utilities-----------------------------------------
function [PIXEL_WIDTH-1:0] map_data;
    input [MAP_X_WIDTH-1:0] x_pos;
    input [MAP_Y_WIDTH-1:0] y_pos;
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
        IDLE, LEFT, RIGHT: begin // 看要不要改成 prority_decoder
            if (detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg, map)) begin
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
            if (detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg, map)) begin
                next_state = FALL_TO_GROUND;
            end else if (collision_type > 0) begin
                next_state = COLLISION;
            end else if (max_charge || jump_btn_negedge) begin
                next_state = JUMP;
            end else begin
                next_state = CHARGE;
            end
        end
        JUMP, FALL_TO_GROUND, COLLISION: begin
            if (detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg, map)) begin
                next_state = FALL_TO_GROUND;
            end else if (collision_type > 0) begin
                next_state = COLLISION;
            end else begin
                next_state = IDLE;
            end
        end
        default: begin
            if (detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg, map)) begin
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
//有問題，fall to ground時會回不來
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
    if (detect_on_ground(pos_x_reg, pos_y_reg, map)) begin
        acc_x = 0;
        acc_y = 0;
    end else begin
        acc_x = 0;
        acc_y = -GRAVITY;
    end
end

always @(*) begin
    if (detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg, map)) begin
        vel_x = -vel_x_reg;
        vel_y = -vel_y_reg;
    end else if (collision_type == 1) begin
        vel_x = 0;
        vel_y = -2 * vel_y_reg;
    end else if (collision_type == 2) begin
        vel_x = -2 * vel_x_reg;
        vel_y = 0;
    end else if (Q == CHARGE && (max_charge || !jump_btn)) begin
        vel_x = JUMP_VEL_X * $clog2(jump_cnt) * face;
        vel_y = JUMP_VEL_Y * $clog2(jump_cnt);
    end
end

always @(*) begin
    if (detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg, map)) begin
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

// 不會用到
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
function [MAP_X_WIDTH + MAP_Y_WIDTH-1:0] calculate_impact_pos;
    input [MAP_X_WIDTH-1:0] pos_x_reg;
    input [MAP_Y_WIDTH-1:0] pos_y_reg;
    input [PHY_WIDTH-1:0] vel_x_reg;
    input [PHY_WIDTH-1:0] vel_y_reg;
    input [MAP_X * MAP_Y * PIXEL_WIDTH-1:0] map;
    integer i;

    reg distance_to_ground;
    begin
        for (i = pos_y_reg + 1; i < MAP_Y; i = i + 1) begin
            if (map_data(pos_x_reg, i, map) == MOVABLE_PIXEL_ID) begin
                distance_to_ground = i - pos_y_reg;
                i = MAP_Y; // break out of loop
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
function [1:0] detect_collision; // 會掃描完所以Character pixel
    input [MAP_X_WIDTH-1:0] pos_x_reg;
    input [MAP_Y_WIDTH-1:0] pos_y_reg;
    input [MAP_X * MAP_Y * PIXEL_WIDTH-1:0] map;
    integer i, k;

    reg [1:0] row_dectection; // 0: no detect, 1: detect once, 2: detect twice
    reg [1:0] col_detection; // 0: no detect, 1: detect once, 2: detect twice
    begin
        for (i = 0; i < CHAR_WIDTH_Y; i = i + 1) begin
            row_detection = 0;
            for (k = 0; k < CHAR_WIDTH_X; k = k + 1) begin
                if (map_data(pos_x_reg + k, pos_y_reg + i, map) == OBSTACLE_PIXEL_ID && row_dectection == 1) begin
                    row_detection = 2;
                    k = CHAR_WIDTH_X;
                    i = CHAR_WIDTH_Y; // break out of both loops
                end else if (map_data(pos_x_reg + k, pos_y_reg + i, map) == OBSTACLE_PIXEL_ID) begin
                    row_detection = 1;
                end else begin
                    row_detection = 0;
                end
            end
        end

        for (i = 0; i < CHAR_WIDTH_X; i = i + 1) begin
            col_detection = 0;
            for (k = 0; k < CHAR_WIDTH_Y; k = k + 1) begin
                if (map_data(pos_x_reg + i, pos_y_reg + k, map) == OBSTACLE_PIXEL_ID && col_detection == 1) begin
                    col_detection = 2;
                    i = CHAR_WIDTH_X;
                    k = CHAR_WIDTH_Y; // break out of both loops
                end else if (map_data(pos_x_reg + i, pos_y_reg + k, map) == OBSTACLE_PIXEL_ID) begin
                    col_detection = 1;
                end else begin
                    col_detection = 0;
                end
            end
        end

        if (row_detection == 2) begin
            detect_collision = 1; // higher priority
        end else if (col_detection == 2) begin
            detect_collision = 2;
        end else begin
            detect_collision = 0;
        end
    end
endfunction

function detect_fall_to_ground;
    input [MAP_X_WIDTH-1:0] pos_x_reg;
    input [MAP_Y_WIDTH-1:0] pos_y_reg;
    input [PHY_WIDTH-1:0] vel_y_reg;
    input [MAP_X * MAP_Y * PIXEL_WIDTH-1:0] map;
    integer i;
    begin
        detect_fall_to_ground = (collision_type == 1) && (vel_y_reg < 0);
    end
endfunction

function detect_on_ground;
    input [MAP_X_WIDTH-1:0] pos_x_reg;
    input [MAP_Y_WIDTH-1:0] pos_y_reg;
    input [PHY_WIDTH-1:0] vel_y_reg;
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