// TODO:
// debug mode, character can move up / down. up velocity is larger than gravity
// jump factor change to addition-based
// smooth velocity, divider by 100 to increase char_clk by 10 times
// print character state
// deal with coillide to long, add an velocity
module tb_character #(
    parameter PHY_WIDTH = 14,
    parameter PIXEL_WIDTH = 12,
    parameter SIGNED_PHY_WIDTH = PHY_WIDTH + 1,
    parameter SMOOTH_FACTOR = 7, // represent the power of 2, Max = 7
    //-----------Map Parameters-----------
    parameter WALL_WIDTH = 10,
    parameter MAP_WIDTH_X = 480,
    //parameter MAP_WIDTH_Y = 100,
    parameter MAP_X_OFFSET = 120, // (640 - 480) / 2
    parameter MAP_Y_OFFSET = 0,
    parameter LEFT_WALL = MAP_WIDTH_X - WALL_WIDTH + MAP_X_OFFSET,
    parameter RIGHT_WALL = MAP_X_OFFSET,
    //parameter TOP_WALL = MAP_WIDTH_Y - WALL_WIDTH + MAP_Y_OFFSET,
    parameter BOTTOM_WALL = MAP_Y_OFFSET,
    //-----------Character Parameters-----
    parameter CHAR_WIDTH_X = 32,
    parameter CHAR_WIDTH_Y = 32,
    parameter signed INITIAL_POS_X = 554,//MAP_X_OFFSET + (MAP_WIDTH_X - CHAR_WIDTH_X) / 2,
    parameter signed INITIAL_POS_Y = 409,//MAP_Y_OFFSET + WALL_WIDTH,
    parameter signed INITIAL_VEL_X = 1984,
    parameter signed INITIAL_VEL_Y = -2944,
    //-----------Obstacle Parameters-----
    parameter OBSTACLE_NUM = 7,
    parameter OBSTACLE_WIDTH = 10,
    parameter OBSTACLE_HEIGHT = 20,
    parameter BLOCK_LEN_WIDTH = 4 // max 15
    ) (
    input sys_clk,
    input character_clk,
    input sys_rst_n,
    input left_btn,
    input right_btn,
    input jump_btn,
    input [OBSTACLE_NUM * PHY_WIDTH-1:0] obstacle_abs_pos_x, // obstacle absolute x position
    input [OBSTACLE_NUM * PHY_WIDTH-1:0] obstacle_abs_pos_y, // obstacle absolute y position
    input [OBSTACLE_NUM * BLOCK_LEN_WIDTH-1:0] obstacle_block_width, // obstacle block width
    output [SIGNED_PHY_WIDTH-1:0] out_pos_x, // character absolute x position
    output [SIGNED_PHY_WIDTH-1:0] out_pos_y, // character absolute y position
    output [SIGNED_PHY_WIDTH-1:0] out_vel_x,
    output [SIGNED_PHY_WIDTH-1:0] out_vel_y,
    output [SIGNED_PHY_WIDTH-1:0] out_acc_x,
    output [SIGNED_PHY_WIDTH-1:0] out_acc_y,
    output [1:0] out_face,
    output [7:0] out_jump_cnt,
    output [3:0] out_state,
    output [2:0] out_collision_type,
    output [1:0] out_fall_to_ground,
    output [1:0] out_on_ground,
    output out_left_btn_posedge,
    output out_right_btn_posedge,
    output out_jump_btn_posedge,
    //debug
    output [SIGNED_PHY_WIDTH-1:0] out_dis_to_ob,
    output [1:0] out_row_detect,
    output [1:0] out_is_hold,
    output [1:0] out_hold,
    output [$clog2(OBSTACLE_NUM+5):0] out_ob_detect
);


// FSM variables
localparam [2:0] IDLE = 0, LEFT = 1, RIGHT = 2, CHARGE = 3, JUMP = 4, COLLISION = 5, FALL_TO_GROUND = 6, HOLD = 7;
reg [2:0] state, next_state;

// physics simulation
// SMOOTH_FACTOR Maximum is 7
localparam signed [SIGNED_PHY_WIDTH-1:0] MAX_VEL = $signed((WALL_WIDTH + CHAR_WIDTH_Y - 2) <<< SMOOTH_FACTOR); // assure that the character can not pass the wall without being detected
localparam signed [SIGNED_PHY_WIDTH-1:0] MAX_DISPLACEMENT = (WALL_WIDTH + CHAR_WIDTH_Y - 2);
localparam signed [SIGNED_PHY_WIDTH-1:0] GRAVITY = -(1 <<< SMOOTH_FACTOR);
localparam signed [SIGNED_PHY_WIDTH-1:0] POSITIVE = 1 <<< SMOOTH_FACTOR;
localparam signed [SIGNED_PHY_WIDTH-1:0] LEFT_POS_X = 3;
localparam signed [SIGNED_PHY_WIDTH-1:0] RIGHT_POS_X = -3;
localparam signed [SIGNED_PHY_WIDTH-1:0] JUMP_VEL_X = 2 <<< SMOOTH_FACTOR;
localparam signed [SIGNED_PHY_WIDTH-1:0] JUMP_VEL_Y = 5 <<< SMOOTH_FACTOR;
localparam signed [SIGNED_PHY_WIDTH-1:0] FALLING_VEL_THRESHOLD = -MAX_VEL / 3;

reg signed [SIGNED_PHY_WIDTH-1:0] acc_x_reg, acc_y_reg; // SIGNED_PHY_WIDTH-bit signed integer
reg signed [SIGNED_PHY_WIDTH-1:0] vel_x_reg, vel_y_reg;
reg signed [SIGNED_PHY_WIDTH-1:0] pos_x_reg, pos_y_reg;
reg signed [SIGNED_PHY_WIDTH-1:0] acc_x, acc_y;
reg signed [SIGNED_PHY_WIDTH-1:0] vel_x, vel_y;
reg signed [SIGNED_PHY_WIDTH-1:0] pos_x, pos_y;
reg signed [SIGNED_PHY_WIDTH-1:0] pos_x_next, pos_y_next;
reg signed [SIGNED_PHY_WIDTH-1:0] vel_x_next, vel_y_next;

reg signed [SIGNED_PHY_WIDTH-1:0] pos_x_reg_d, pos_y_reg_d;

// 0: no face, 1: face left, -1: face right
reg signed [1:0] face;

// jump cnt
localparam [6:0]MAX_CHARGE = 100;
localparam [6:0] JUMP_INCREMENT = 5;
reg [6:0] jump_cnt;
reg signed [SIGNED_PHY_WIDTH-1:0] jump_factor;
wire max_charge;

// collision signal
reg [1:0] collision_type;
reg [1:0] collision_type_next;
reg fall_to_ground;
reg fall_to_ground_next;
reg on_ground;
reg on_ground_next;

// button edge detection
wire left_btn_posedge, right_btn_posedge, jump_btn_posedge;
reg left_btn_d, right_btn_d, jump_btn_d;
reg jump_btn_posedge_flag;

// collision detect
wire [1:0] wall_detect;
reg [MAX_DISPLACEMENT+1:0] ob_detect_row;
reg [$clog2(OBSTACLE_NUM+5)-1:0] ob_id; // default value == OBSTACLE_NUM
reg [$clog2(OBSTACLE_NUM+5)-1:0] collision_id; // default value == OBSTACLE_NUM
reg ob_detect_below;

// hold signal to wait for the object until being out of the obstacle
reg [$clog2(OBSTACLE_NUM+5)-1:0] hold;
wire is_hold;

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
assign out_left_btn_posedge = left_btn_posedge;
assign out_right_btn_posedge = right_btn_posedge;
assign out_jump_btn_posedge = jump_btn_posedge;
assign out_is_hold = {1'b0, is_hold};
assign out_hold = {1'b0, hold};

reg character_clk_d;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        character_clk_d <= 0;
    end else begin
        character_clk_d <= character_clk;
    end
end

//--------------------------------------Collision detection-----------------------------------------
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        collision_type <= 0;
        fall_to_ground <= 0;
        on_ground <= 0;
    end else begin
        collision_type_next <= detect_collision(pos_x_reg, pos_y_reg, pos_x_reg_d, pos_y_reg_d);
        collision_type <= collision_type_next;

        fall_to_ground_next <= detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg);
        fall_to_ground <= fall_to_ground_next;

        on_ground_next <= detect_on_ground(pos_x_reg, pos_y_reg);
        on_ground <= on_ground_next;
    end
end
assign wall_detect = detect_wall(pos_x_reg, pos_y_reg);
//--------------------------------------Collision detection-----------------------------------------

//---------------------------------------Hold signal-----------------------------------------
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        hold <= OBSTACLE_NUM;
    end else if (character_clk_d) begin
        hold <= collision_id;
    end
end
assign is_hold = (hold == collision_id) && (hold != OBSTACLE_NUM);
//---------------------------------------Hold signal-----------------------------------------


//--------------------------------------Button signals-----------------------------------------
always @(posedge sys_clk or negedge sys_rst_n) begin
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
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        jump_btn_posedge_flag <= 0;
    end else if (jump_btn_posedge && on_ground) begin
        jump_btn_posedge_flag <= 1;
    end else if (state == JUMP) begin
        jump_btn_posedge_flag <= 0;
    end
end
assign left_btn_posedge = ~left_btn_d && left_btn;
assign right_btn_posedge = ~right_btn_d && right_btn;
assign jump_btn_posedge = ~jump_btn_d && jump_btn;
//--------------------------------------Button signals-----------------------------------------


//-----------------------------------------FSM-----------------------------------------
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        state <= IDLE;
    end else if (character_clk_d) begin
        state <= next_state;
    end
end

always @(*) begin
    if (is_hold) begin
        next_state = HOLD;
    end else if (fall_to_ground) begin
        next_state = FALL_TO_GROUND;
    end else if (collision_type > 0) begin
        next_state = COLLISION;
    end else begin
        case (state)
            IDLE, LEFT, RIGHT: begin
                if (on_ground) begin
                    if (left_btn_d) begin
                        next_state = LEFT;
                    end else if (right_btn_d) begin
                        next_state = RIGHT;
                    end else if (jump_btn_posedge_flag) begin
                        next_state = CHARGE;
                    end else begin
                        next_state = IDLE;
                    end
                end else begin 
                    next_state = IDLE;
                end
            end
            CHARGE: begin
                if (max_charge || ~jump_btn_d) begin
                    next_state = JUMP;
                end else begin
                    next_state = CHARGE;
                end
            end
            JUMP, FALL_TO_GROUND, COLLISION: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end
end
assign max_charge = (state == CHARGE) && (jump_cnt >= MAX_CHARGE);
//-----------------------------------------FSM-----------------------------------------



//-----------------------------------------Character Movement-----------------------------------------
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        jump_cnt <= 1;
    end else if (character_clk_d) begin
        if (state == CHARGE) begin
            jump_cnt <= jump_cnt + JUMP_INCREMENT;
        end else if (state == JUMP) begin
            jump_cnt <= 1;
        end
    end
end

always @(*) begin
    jump_factor = {3'b0, jump_cnt[6:4], 1'b1, 8'b0} + {6'b0, jump_cnt[3:2], 7'b0} + {7'b0, jump_cnt[1:0],6'b0};
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        face <= 1;
    end else if (character_clk_d) begin
        if (collision_type == 2) begin
            face <= -face;
        end else if (state == LEFT) begin
            face <= 1;
        end else if (state == RIGHT) begin
            face <= -1;
        end
    end
end

always @(*) begin
    if (is_hold) begin
        acc_x = 0;
        acc_y = GRAVITY;
    end else if (on_ground || fall_to_ground) begin
        acc_x = 0;
        acc_y = 0;
    end else begin
        acc_x = 0;
        acc_y = GRAVITY;
    end
end

always @(*) begin
    if (is_hold) begin
        vel_x = 0;
        vel_y = 0;
    end else if (fall_to_ground) begin
        vel_x = -vel_x_reg;
        vel_y = -vel_y_reg;
    end else if (collision_type == 1) begin
        vel_x = 0;
        vel_y = -2 * vel_y_reg;
    end else if (collision_type == 2) begin
        vel_x = -2 * vel_x_reg;
        vel_y = 0;
    end else if (state == JUMP) begin
        vel_x = (JUMP_VEL_X + $signed(jump_factor) >>> 1) * face;
        vel_y = (JUMP_VEL_Y + jump_factor);
    end else begin
        vel_x = 0;
        vel_y = 0;
    end
end

always @(*) begin
    if (is_hold) begin
        pos_x = 0;
        pos_y = 0;
    end else if (fall_to_ground) begin
        {pos_x, pos_y} = calculate_impact_pos(pos_x_reg, pos_y_reg, vel_x_reg, vel_y_reg);
    end else if (state == LEFT) begin
        pos_x = LEFT_POS_X;
        pos_y = 0;
    end else if (state == RIGHT) begin
        pos_x = RIGHT_POS_X;
        pos_y = 0;
    end else begin
        pos_x = 0;
        pos_y = 0;
    end
end

// determine the max, min of the velocity, position
always @(*) begin
    if (vel_x_reg + vel_x + acc_x >= MAX_VEL) begin
        vel_x_next = MAX_VEL;
    end else if (vel_x_reg + vel_x + acc_x < -MAX_VEL) begin
        vel_x_next = -MAX_VEL;
    end else begin
        vel_x_next = vel_x_reg + vel_x + acc_x;
    end

    if (vel_y_reg + vel_y + acc_y >= MAX_VEL) begin
        vel_y_next = MAX_VEL;
    end else if (vel_y_reg + vel_y + acc_y < -MAX_VEL) begin
        vel_y_next = -MAX_VEL;
    end else begin
        vel_y_next = vel_y_reg + vel_y + acc_y;
    end
end

//注意這邊只有檢查到牆壁, 沒有障礙物
always @(*) begin
    if (pos_x_reg + pos_x + CHAR_WIDTH_X - 1 >= LEFT_WALL) begin
        pos_x_next = LEFT_WALL - CHAR_WIDTH_X;
    end else if (pos_x_reg + pos_x < RIGHT_WALL + WALL_WIDTH) begin
        pos_x_next = RIGHT_WALL + WALL_WIDTH;
    end else begin
        pos_x_next = pos_x_reg + pos_x;
    end

    /*if (pos_y_reg + pos_y + CHAR_WIDTH_Y - 1 >= TOP_WALL) begin
        pos_y_next = TOP_WALL - CHAR_WIDTH_Y;*/
    if (pos_y_reg + pos_y < BOTTOM_WALL + WALL_WIDTH) begin
        pos_y_next = BOTTOM_WALL + WALL_WIDTH;
    end else begin
        pos_y_next = pos_y_reg + pos_y;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        acc_x_reg <= 0;
        acc_y_reg <= 0;
    end else if (character_clk_d) begin
        acc_x_reg <= acc_x_reg + acc_x;
        acc_y_reg <= acc_y_reg + acc_y;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        vel_x_reg <= INITIAL_VEL_X;
        vel_y_reg <= INITIAL_VEL_Y;
    end else if (character_clk_d) begin
        vel_x_reg <= vel_x_next;
        vel_y_reg <= vel_y_next;
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        pos_x_reg <= INITIAL_POS_X;
        pos_y_reg <= INITIAL_POS_Y;
    end else if (character_clk_d) begin
        pos_x_reg <= pos_x_next + ($signed(vel_x_next) >>> SMOOTH_FACTOR);
        pos_y_reg <= pos_y_next + ($signed(vel_y_next) >>> SMOOTH_FACTOR);
    end
end

// delay the position by 1 clock cycle to detect the collision
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        pos_x_reg_d <= INITIAL_POS_X;
        pos_y_reg_d <= INITIAL_POS_Y;
    end else if (character_clk_d) begin
        pos_x_reg_d <= pos_x_reg;
        pos_y_reg_d <= pos_y_reg;
    end
end

//-----------------------------------------Character Movement-----------------------------------------

//-----------------------------------------detect wall-----------------------------------------
function automatic [1:0] detect_wall; // 0 for no wall, 1 for left wall, 2 for right wall, 3 for bottom wall
    input signed [SIGNED_PHY_WIDTH-1:0] pos_x_reg;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_y_reg;
    begin
        if(pos_x_reg + CHAR_WIDTH_X - 1 >= LEFT_WALL) begin
            detect_wall = 1;
        end else if (pos_x_reg < RIGHT_WALL + WALL_WIDTH) begin
            detect_wall = 2;
        end else if (pos_y_reg < BOTTOM_WALL + WALL_WIDTH) begin
            detect_wall = 3;
        end else begin
            detect_wall = 0;
        end
    end
endfunction
//-----------------------------------------detect wall-----------------------------------------

//-----------------------------------------detect obstacle-----------------------------------------
wire [OBSTACLE_NUM*SIGNED_PHY_WIDTH-1:0] obstacle_signed_abs_pos_x;
wire [OBSTACLE_NUM*SIGNED_PHY_WIDTH-1:0] obstacle_signed_abs_pos_y;

genvar k;
generate
    for (k = 0; k < OBSTACLE_NUM; k = k + 1) begin
        assign obstacle_signed_abs_pos_x[k*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH] = {1'b0, obstacle_abs_pos_x[k*PHY_WIDTH +: PHY_WIDTH]};
        assign obstacle_signed_abs_pos_y[k*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH] = {1'b0, obstacle_abs_pos_y[k*PHY_WIDTH +: PHY_WIDTH]};
    end
endgenerate

function automatic in_obstacle;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_x;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_y;
    input signed [SIGNED_PHY_WIDTH-1:0] obstacle_x;
    input signed [SIGNED_PHY_WIDTH-1:0] obstacle_y;
    input [BLOCK_LEN_WIDTH-1:0] obstacle_len;
    begin
        in_obstacle = (pos_x >= obstacle_x &&
            pos_x < obstacle_x + obstacle_len * OBSTACLE_WIDTH &&
            pos_y >= obstacle_y && 
            pos_y < obstacle_y + OBSTACLE_HEIGHT);
    end
endfunction

integer a, b;
always @(*) begin
    ob_id = OBSTACLE_NUM;
    for (a = 0; a <= MAX_DISPLACEMENT + 1; a = a + 1) begin
        ob_detect_row[a] = 1'b1;
        for (b = 0; b < OBSTACLE_NUM; b = b + 1) begin
            if (in_obstacle(pos_x_reg, pos_y_reg + a, obstacle_signed_abs_pos_x[b*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH], obstacle_signed_abs_pos_y[b*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH], obstacle_block_width[b*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH]) ||
                in_obstacle(pos_x_reg + CHAR_WIDTH_X - 1, pos_y_reg + a, obstacle_signed_abs_pos_x[b*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH], obstacle_signed_abs_pos_y[b*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH], obstacle_block_width[b*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH])) begin
                ob_detect_row[a] = 1'b0;
                if(a < CHAR_WIDTH_Y) begin
                    ob_id = b;
                end
            end
        end
    end
end

always @(*) begin
    ob_detect_below = 1'b1;
    for (b = 0; b < OBSTACLE_NUM; b = b + 1) begin
        if (in_obstacle(pos_x_reg, pos_y_reg - 1, obstacle_signed_abs_pos_x[b*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH], obstacle_signed_abs_pos_y[b*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH], obstacle_block_width[b*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH]) || 
            in_obstacle(pos_x_reg + CHAR_WIDTH_X - 1, pos_y_reg - 1, obstacle_signed_abs_pos_x[b*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH], obstacle_signed_abs_pos_y[b*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH], obstacle_block_width[b*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH])) begin
            ob_detect_below = 1'b0;
        end
    end
end

//-----------------------------------------detect obstacle-----------------------------------------

//-----------------------------------------detect obstacle and wall------------------------------------
always @(*) begin
    collision_id = (wall_detect == 0) ? ob_id : wall_detect + OBSTACLE_NUM;
end
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
wire [MAX_DISPLACEMENT+1:0] row_detect; // 1 for no collision, 0 for collision
wire row_detect_below; // for a block below the character

genvar i;
generate
    for (i = 0; i <= MAX_DISPLACEMENT+1; i = i + 1) begin
        assign row_detect[i] = (i + pos_y_reg >= BOTTOM_WALL + WALL_WIDTH) && ob_detect_row[i];
    end
endgenerate

assign row_detect_below = (pos_y_reg - 1 >= BOTTOM_WALL + WALL_WIDTH) && ob_detect_below;
//-----------------------------------------detect boundary-----------------------------------------

//-----------------------------------------Push Character to the Ground-----------------------------------------
function automatic signed [SIGNED_PHY_WIDTH-1:0] multi_div;
    input signed [SIGNED_PHY_WIDTH-1:0] org;
    input signed [SIGNED_PHY_WIDTH-1:0] mul;
    input signed [SIGNED_PHY_WIDTH-1:0] div;
    reg signed [SIGNED_PHY_WIDTH + SIGNED_PHY_WIDTH - 1:0] result;
    begin
        result = org * mul;
        if (div == 0) begin
            multi_div = 0;
        end else begin
            multi_div = result / div;
        end
    end
endfunction

// debug
wire signed [SIGNED_PHY_WIDTH + SIGNED_PHY_WIDTH - 1:0] impact_pos_result;

assign impact_pos_result = calculate_impact_pos(pos_x_reg, pos_y_reg, vel_x_reg, vel_y_reg);
assign out_dis_to_ob = impact_pos_result[SIGNED_PHY_WIDTH-1:0];
assign out_row_detect = {1'b0, |row_detect};
assign out_ob_detect = {1'b0, collision_id};

function signed [SIGNED_PHY_WIDTH + SIGNED_PHY_WIDTH - 1:0] calculate_impact_pos;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_x_reg;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_y_reg;
    input signed [SIGNED_PHY_WIDTH-1:0] vel_x_reg;
    input signed [SIGNED_PHY_WIDTH-1:0] vel_y_reg;
    integer i;

    reg signed [SIGNED_PHY_WIDTH-1:0] distance_to_nearest_ob;
    reg signed [SIGNED_PHY_WIDTH-1:0] impact_pos_x;
    begin
        distance_to_nearest_ob = 0;
        if (row_detect[0]) begin // if the bottom of the character is not fully in the wall
            for (i = 1; i <= MAX_DISPLACEMENT+1; i = i + 1) begin
                if (!row_detect[i] && distance_to_nearest_ob == 0) begin
                    distance_to_nearest_ob = i + WALL_WIDTH;
                end
            end
        end else begin // if the bottom of the character is fully in the wall
            for (i = 1; i <= MAX_DISPLACEMENT+1; i = i + 1) begin
                if (row_detect[i] && distance_to_nearest_ob == 0) begin
                    distance_to_nearest_ob = i;
                end
            end
        end

        impact_pos_x = multi_div(vel_x_reg, distance_to_nearest_ob, vel_y_reg);

        calculate_impact_pos = {impact_pos_x, distance_to_nearest_ob};
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
function automatic [1:0] detect_collision;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_x_reg;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_y_reg;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_x_reg_d;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_y_reg_d;
    integer i;

    begin
        if (collision_id > OBSTACLE_NUM) begin // collide with wall
            if (wall_detect == 3) begin
                detect_collision = 1;
            end else begin
                 detect_collision = 2;
            end
        end else if (collision_id < OBSTACLE_NUM) begin // collide with obstacle
            if (pos_x_reg_d >= obstacle_signed_abs_pos_x[collision_id*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH] + obstacle_block_width[collision_id*BLOCK_LEN_WIDTH +: BLOCK_LEN_WIDTH] * OBSTACLE_WIDTH ||
                    pos_x_reg_d + CHAR_WIDTH_X - 1 < obstacle_signed_abs_pos_x[collision_id*SIGNED_PHY_WIDTH +: SIGNED_PHY_WIDTH]) begin
                detect_collision = 2; // horizontal collision
            end else begin
                detect_collision = 1; // vertical collision
            end
        end else begin
            detect_collision = 0;
        end
    end
endfunction

function automatic detect_fall_to_ground;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_x_reg;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_y_reg;
    input signed [SIGNED_PHY_WIDTH-1:0] vel_y_reg;
    begin
        detect_fall_to_ground = (collision_type == 1) && (vel_y_reg < 0) && (on_ground == 0);
    end
endfunction

function automatic detect_on_ground;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_x_reg;
    input signed [SIGNED_PHY_WIDTH-1:0] pos_y_reg;
    begin
        detect_on_ground =  (row_detect[0] && !row_detect_below);
    end
endfunction
//-----------------------------------------Character Detection-----------------------------------------




//-----------------------------------------Character Display-----------------------------------------

//-----------------------------------------Character Display-----------------------------------------

endmodule