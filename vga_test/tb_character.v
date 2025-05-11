// jump factor change to addition-based
// continuous right, left like jump_btn
// smooth velocity, divider by 100 to increase char_clk by 10 times
// change button xdc
module tb_character #(
    parameter PHY_WIDTH = 10,
    parameter PIXEL_WIDTH = 12,
    //-----------Map Parameters-----------
    parameter WALL_WIDTH = 10,
    parameter MAP_WIDTH_X = 100,
    parameter MAP_WIDTH_Y = 100,
    parameter MAP_X_OFFSET = 270,
    parameter MAP_Y_OFFSET = 50,
    parameter LEFT_WALL = MAP_WIDTH_X - WALL_WIDTH + MAP_X_OFFSET,
    parameter RIGHT_WALL = MAP_X_OFFSET,
    parameter TOP_WALL = MAP_WIDTH_Y - WALL_WIDTH + MAP_Y_OFFSET,
    parameter BOTTOM_WALL = MAP_Y_OFFSET,
    //-----------Character Parameters-----
    parameter CHAR_WIDTH_X = 32,
    parameter CHAR_WIDTH_Y = 32,
    parameter INITIAL_POS_X = MAP_X_OFFSET + (MAP_WIDTH_X - CHAR_WIDTH_X) / 2,
    parameter INITIAL_POS_Y = MAP_Y_OFFSET + (MAP_WIDTH_Y - CHAR_WIDTH_Y) / 2
     ) (
    input sys_clk,
    input character_clk,
    input sys_rst_n,
    input left_btn,
    input right_btn,
    input jump_btn,
    output [PHY_WIDTH:0] out_pos_x, // character x offset
    output [PHY_WIDTH:0] out_pos_y, // character y offset
    output [PHY_WIDTH:0] out_vel_x,
    output [PHY_WIDTH:0] out_vel_y,
    output [PHY_WIDTH:0] out_acc_x,
    output [PHY_WIDTH:0] out_acc_y,
    output [1:0] out_face,
    output [7:0] out_jump_cnt,
    output [3:0] out_state,
    output [2:0] out_collision_type,
    output [1:0] out_fall_to_ground,
    output [1:0] out_on_ground,
    output [1:0] out_left_btn_posedge,
    output [1:0] out_right_btn_posedge,
    output [1:0] out_jump_btn_posedge,
    //debug
    output [PHY_WIDTH:0] out_dis_to_ob,
    output [16:0] out_row_detect
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
assign out_left_btn_posedge = {1'b0, left_btn_posedge};
assign out_right_btn_posedge = {1'b0, right_btn_posedge};
assign out_jump_btn_posedge = {1'b0, jump_btn_posedge};

// FSM variables
localparam [2:0] IDLE = 0, LEFT = 1, RIGHT = 2, CHARGE = 3, JUMP = 4, COLLISION = 5, FALL_TO_GROUND = 6;
reg [2:0] state, next_state;

// physics simulation
localparam signed [PHY_WIDTH:0] MAX_VEL = WALL_WIDTH + CHAR_WIDTH_Y - 2; // assure that the character can not pass the wall without being detected
localparam signed [PHY_WIDTH:0] GRAVITY = -1;
localparam signed [PHY_WIDTH:0] POSITIVE = 1;
localparam signed [PHY_WIDTH:0] LEFT_VEL_X = 1;
localparam signed [PHY_WIDTH:0] RIGHT_VEL_X = -1;
localparam signed [PHY_WIDTH:0] JUMP_VEL_X = 4;
localparam signed [PHY_WIDTH:0] JUMP_VEL_Y = 8;
localparam signed [PHY_WIDTH:0] FALLING_VEL_THRESHOLD = -MAX_VEL / 3;

reg signed [PHY_WIDTH:0] acc_x_reg, acc_y_reg; // 11-bit signed integer
reg signed [PHY_WIDTH:0] vel_x_reg, vel_y_reg;
reg signed [PHY_WIDTH:0] pos_x_reg, pos_y_reg;
reg signed [PHY_WIDTH:0] acc_x, acc_y;
reg signed [PHY_WIDTH:0] vel_x, vel_y;
reg signed [PHY_WIDTH:0] pos_x, pos_y;
reg signed [PHY_WIDTH:0] pos_x_next, pos_y_next;
reg signed [PHY_WIDTH:0] vel_x_next, vel_y_next;

// 0: no face, 1: face left, -1: face right
reg signed [1:0] face;

// jump cnt
localparam MAX_CHARGE = 100;
localparam JUMP_INCREMENT = 10;
reg [6:0] jump_cnt;
reg signed [3:0] jump_factor;
wire max_charge;

// collision signal
reg [1:0] collision_type;
reg [1:0] collision_type_next;
reg fall_to_ground;
reg fall_to_ground_next;
reg on_ground;
reg on_ground_next;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        collision_type <= 0;
        fall_to_ground <= 0;
        on_ground <= 0;
    end else begin
        collision_type_next <= detect_collision(pos_x_reg, pos_y_reg);
        collision_type <= collision_type_next;

        fall_to_ground_next <= detect_fall_to_ground(pos_x_reg, pos_y_reg, vel_y_reg);
        fall_to_ground <= fall_to_ground_next;

        on_ground_next <= detect_on_ground(pos_x_reg, pos_y_reg);
        on_ground <= on_ground_next;
    end
end



// button edge detection
wire left_btn_posedge, right_btn_posedge, jump_btn_posedge;
reg left_btn_d, right_btn_d, jump_btn_d;
reg left_btn_posedge_flag, right_btn_posedge_flag, jump_btn_posedge_flag;

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
        left_btn_posedge_flag <= 0;
        right_btn_posedge_flag <= 0;
        jump_btn_posedge_flag <= 0;
    end else if (left_btn_posedge) begin
        left_btn_posedge_flag <= 1;
    end else if (right_btn_posedge) begin
        right_btn_posedge_flag <= 1;
    end else if (jump_btn_posedge) begin
        jump_btn_posedge_flag <= 1;
    end else if (state == LEFT || state == RIGHT || state == JUMP) begin
        left_btn_posedge_flag <= 0;
        right_btn_posedge_flag <= 0;
        jump_btn_posedge_flag <= 0;
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
    if (fall_to_ground) begin
        next_state = FALL_TO_GROUND;
    end else if (collision_type > 0) begin
        next_state = COLLISION;
    end else begin
        case (state)
            IDLE, LEFT, RIGHT: begin
                if (on_ground) begin
                    if (left_btn_posedge_flag) begin
                        next_state = LEFT;
                    end else if (right_btn_posedge_flag) begin
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
                if (max_charge || ~jump_btn) begin
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

always @(*) begin
    if (jump_cnt <= MAX_CHARGE / 4) begin
        jump_factor = 1;
    end else if (jump_cnt <= MAX_CHARGE * 2 / 4) begin
        jump_factor = 2;
    end else if (jump_cnt <= MAX_CHARGE * 3 / 4) begin
        jump_factor = 3;
    end else begin
        jump_factor = 4;
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
    if (on_ground || fall_to_ground) begin
        acc_x = 0;
        acc_y = 0;
    end else begin
        acc_x = 0;
        acc_y = GRAVITY;
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
    end else if (state == JUMP) begin
        vel_x = JUMP_VEL_X * jump_factor * face;
        vel_y = JUMP_VEL_Y * jump_factor;
    end else begin
        vel_x = 0;
        vel_y = 0;
    end
end

always @(*) begin
    if (fall_to_ground) begin
        {pos_x, pos_y} = calculate_impact_pos(pos_x_reg, pos_y_reg, vel_x_reg, vel_y_reg);
    end else if (state == LEFT) begin
        pos_x = LEFT_VEL_X;
        pos_y = 0;
    end else if (state == RIGHT) begin
        pos_x = RIGHT_VEL_X;
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

always @(*) begin
    if (pos_x_reg + pos_x + CHAR_WIDTH_X - 1 >= LEFT_WALL) begin
        pos_x_next = LEFT_WALL - CHAR_WIDTH_X;
    end else if (pos_x_reg + pos_x < RIGHT_WALL + WALL_WIDTH) begin
        pos_x_next = RIGHT_WALL + WALL_WIDTH;
    end else begin
        pos_x_next = pos_x_reg + pos_x;
    end

    if (pos_y_reg + pos_y + CHAR_WIDTH_Y - 1 >= TOP_WALL) begin
        pos_y_next = TOP_WALL - CHAR_WIDTH_Y;
    end else if (pos_y_reg + pos_y < BOTTOM_WALL + WALL_WIDTH) begin
        pos_y_next = BOTTOM_WALL + WALL_WIDTH;
    end else begin
        pos_y_next = pos_y_reg + pos_y;
    end
end

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
        vel_x_reg <= vel_x_next;
        vel_y_reg <= vel_y_next;
    end
end

always @(posedge character_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        pos_x_reg <= INITIAL_POS_X;
        pos_y_reg <= INITIAL_POS_Y;
    end else begin
        pos_x_reg <= pos_x_next + vel_x_next;
        pos_y_reg <= pos_y_next + vel_y_next;
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
wire [CHAR_WIDTH_X-1:0] col_detect;
wire [MAX_VEL+1:0] row_detect;
wire row_detect_below; // for a block below the character

genvar i;
generate
    for (i = 0; i < CHAR_WIDTH_X; i = i + 1) begin
        assign col_detect[i] = (i + pos_x_reg < LEFT_WALL && i + pos_x_reg >= RIGHT_WALL + WALL_WIDTH);
    end
    for (i = 0; i <= MAX_VEL+1; i = i + 1) begin
        assign row_detect[i] = (i + pos_y_reg < TOP_WALL && i + pos_y_reg >= BOTTOM_WALL + WALL_WIDTH);
    end
endgenerate
assign row_detect_below = (pos_y_reg - 1 < TOP_WALL && pos_y_reg - 1 >= BOTTOM_WALL + WALL_WIDTH);
//-----------------------------------------detect boundary-----------------------------------------

//-----------------------------------------Push Character to the Ground-----------------------------------------
function automatic signed [PHY_WIDTH:0] multi_div;
    input signed [PHY_WIDTH:0] org;
    input signed [PHY_WIDTH:0] mul;
    input signed [PHY_WIDTH:0] div;
    reg signed [PHY_WIDTH + PHY_WIDTH + 1:0] result;
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
wire signed [PHY_WIDTH + PHY_WIDTH + 1:0] impact_pos_result;

assign impact_pos_result = calculate_impact_pos(pos_x_reg, pos_y_reg, vel_x_reg, vel_y_reg);
assign out_dis_to_ob = impact_pos_result[PHY_WIDTH:0];
assign out_row_detect = row_detect[16:0];

function signed [PHY_WIDTH + PHY_WIDTH + 1:0] calculate_impact_pos;
    input signed [PHY_WIDTH:0] pos_x_reg;
    input signed [PHY_WIDTH:0] pos_y_reg;
    input signed [PHY_WIDTH:0] vel_x_reg;
    input signed [PHY_WIDTH:0] vel_y_reg;
    integer i;

    reg signed [PHY_WIDTH:0] distance_to_nearest_ob;
    reg signed [PHY_WIDTH:0] impact_pos_x;
    begin
        distance_to_nearest_ob = 0;
        if (row_detect[0]) begin // if the bottom of the character is not fully in the wall
            for (i = 1; i <= MAX_VEL+1; i = i + 1) begin
                if (!row_detect[i] && distance_to_nearest_ob == 0) begin
                    distance_to_nearest_ob = i + WALL_WIDTH;
                end
            end
        end else begin // if the bottom of the character is fully in the wall
            for (i = 1; i <= MAX_VEL+1; i = i + 1) begin
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
    input signed [PHY_WIDTH:0] pos_x_reg;
    input signed [PHY_WIDTH:0] pos_y_reg;
    integer i;

    reg row_detection; // 0: no detect, 1: detect once, 2: detect twice
    reg col_detection; // 0: no detect, 1: detect once, 2: detect twice
    begin
        row_detection = 0;
        col_detection = 0;
        for (i = 0; i < CHAR_WIDTH_Y; i = i + 1) begin
            if (!row_detect[i]) begin
                row_detection = 1;
            end
        end

        for (i = 0; i < CHAR_WIDTH_X; i = i + 1) begin
            if (!col_detect[i]) begin
                col_detection = 1;
            end
        end

        if (row_detection == 1) begin
            detect_collision = 1; // higher priority
        end else if (col_detection == 1) begin
            detect_collision = 2;
        end else begin
            detect_collision = 0;
        end
    end
endfunction

function automatic detect_fall_to_ground;
    input signed [PHY_WIDTH:0] pos_x_reg;
    input signed [PHY_WIDTH:0] pos_y_reg;
    input signed [PHY_WIDTH:0] vel_y_reg;
    begin
        detect_fall_to_ground = (collision_type == 1) && (vel_y_reg < 0) && (on_ground == 0);
    end
endfunction

function detect_on_ground;
    input signed [PHY_WIDTH:0] pos_x_reg;
    input signed [PHY_WIDTH:0] pos_y_reg;
    begin
        detect_on_ground =  (row_detect[0] && !row_detect_below);
    end
endfunction
//-----------------------------------------Character Detection-----------------------------------------




//-----------------------------------------Character Display-----------------------------------------

//-----------------------------------------Character Display-----------------------------------------

endmodule