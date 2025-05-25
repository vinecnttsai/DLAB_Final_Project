module sound_controller(
    input sys_clk,
    input sys_rst_n,
    input is_jump,
    input is_charge,
    input is_hit,
    input is_win,
    output melody_out,
    output bass_out
);

// === 音名定義 ===
parameter C3  = 382226, Db3 = 360773, D3  = 340524, Eb3 = 321412;
parameter E3  = 303373, F3  = 286345, Gb3 = 270545, G3  = 255102;
parameter Ab3 = 240825, A3  = 227272, Bb3 = 214518, B3  = 202478;

parameter C4  = 191113, Db4 = 180387, D4  = 170262, Eb4 = 160706;
parameter E4  = 151687, F4  = 143173, Gb4 = 135272, G4  = 127552;
parameter Ab4 = 120394, A4  = 113636, Bb4 = 107259, B4  = 101239;

parameter C5  = 95556,  Db5 = 90193,  D5  = 85131,  Eb5 = 80352;
parameter E5  = 75843,  F5  = 71586,  Gb5 = 67636,  G5  = 63776;
parameter Ab5 = 60197,  A5  = 56818,  Bb5 = 53629,  B5  = 50619;

parameter C6  = 47778;
parameter REST = 32'hFFFF_FFFF;
parameter WIN_BEAT = 15000000;

// === WIN MUSIC (雙軌, 撥完自動停, 中途不可中斷) ===
reg [31:0] win_melody [0:47];
reg [31:0] win_bass [0:47];

reg [5:0] win_idx = 0;
reg [31:0] win_beat_counter = 0;
reg [31:0] win_melody_freq = REST;
reg [31:0] win_bass_freq = REST;
reg win_playing = 0;
reg win_triggered = 0;

initial begin
    win_melody[0]=G3;   win_bass[0]=REST;
    win_melody[1]=C4;   win_bass[1]=E3;
    win_melody[2]=E4;   win_bass[2]=G3;
    
    win_melody[3]=G4;   win_bass[3]=C4;
    win_melody[4]=C5; win_bass[4]=E4;
    win_melody[5]=E5;   win_bass[5]=G4;
    
    win_melody[6]=G5;   win_bass[6]=C5;
    win_melody[7]=G5;   win_bass[7]=C5;
    win_melody[8]=G5;   win_bass[8]=C5;
    
    win_melody[9]=E5;   win_bass[9]=G4;
    win_melody[10]=E5;  win_bass[10]=G4;
    win_melody[11]=E5;  win_bass[11]=G4;
    
    win_melody[12]=Ab3;  win_bass[12]=REST;
    win_melody[13]=C4;  win_bass[13]=Eb3;
    win_melody[14]=Eb4;  win_bass[14]=Ab3;
    
    win_melody[15]=Ab4;  win_bass[15]=C4;
    win_melody[16]=C5;  win_bass[16]=Eb4;
    win_melody[17]=Eb5;  win_bass[17]=Ab4;
    
    win_melody[18]=Ab5;  win_bass[18]=C4;
    win_melody[19]=Ab5;  win_bass[19]=C4;
    win_melody[20]=Ab5;  win_bass[20]=C4;
    
    win_melody[21]=Eb5;  win_bass[21]=Ab4;
    win_melody[22]=Eb5;  win_bass[22]=Ab4;
    win_melody[23]=Eb5;  win_bass[23]=Ab4;
    
    win_melody[24]=Bb3;  win_bass[24]=REST;
    win_melody[25]=D4;  win_bass[25]=F3;
    win_melody[26]=F4;  win_bass[26]=Bb3;
    
    win_melody[27]=Bb4;  win_bass[27]=D4;
    win_melody[28]=D5;  win_bass[28]=F4;
    win_melody[29]=F5;  win_bass[29]=Bb4;
    
    win_melody[30]=Bb5;  win_bass[30]=D5;
    win_melody[31]=Bb5;  win_bass[31]=D5;
    win_melody[32]=Bb5;  win_bass[32]=D5;
    
    win_melody[33]=Bb5;  win_bass[33]=D5;
    win_melody[34]=Bb5;  win_bass[34]=D5;
    win_melody[35]=Bb5;  win_bass[35]=D5;
    
    win_melody[36]=C6;  win_bass[36]=E5;
    win_melody[37]=C6;  win_bass[37]=E5;
    win_melody[38]=C6;  win_bass[38]=E5;
    
    win_melody[39]=C6;  win_bass[39]=E5;
    win_melody[40]=C6;  win_bass[40]=E5;
    win_melody[41]=C6;  win_bass[41]=E5;
    
    win_melody[42]=REST;  win_bass[42]=REST;
    win_melody[43]=REST;  win_bass[43]=REST;
    win_melody[44]=REST;  win_bass[44]=REST;
    
    win_melody[45]=REST;  win_bass[45]=REST;
    win_melody[46]=REST;  win_bass[46]=REST;
    win_melody[47]=REST;  win_bass[47]=REST;
end

   

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        win_playing <= 0;
        win_triggered <= 0;
        win_idx <= 0;
        win_beat_counter <= 0;
        win_melody_freq <= REST;
        win_bass_freq <= REST;
    end else begin
        if (is_win && !win_triggered && !win_playing) begin
            win_playing <= 1;
            win_triggered <= 1;
            win_idx <= 0;
            win_beat_counter <= 0;
            win_melody_freq <= win_melody[0];
            win_bass_freq <= win_bass[0];
        end

        if (win_playing) begin
            if (win_beat_counter >= WIN_BEAT) begin
                win_beat_counter <= 0;
                win_idx <= win_idx + 1;
                if (win_idx == 47 || win_melody[win_idx + 1] === 32'hxxxx_xxxx) begin
                    win_playing <= 0;
                    win_triggered <= 0;
                    win_melody_freq <= REST;
                    win_bass_freq <= REST;
                end else begin
                    win_melody_freq <= win_melody[win_idx + 1];
                    win_bass_freq <= win_bass[win_idx + 1];
                end
            end else begin
                win_beat_counter <= win_beat_counter + 1;
            end
        end
    end
end

wire win_melody_out, win_bass_out;
timer t_win_m(.sys_clk(sys_clk), .target(win_melody_freq), .sound(win_melody_out));
timer t_win_b(.sys_clk(sys_clk), .target(win_bass_freq), .sound(win_bass_out));

// === JUMP 音效 ===
wire [31:0] jump_freq = (is_jump && !win_playing) ? 32'd95556 : REST;
wire jump_out;
timer t_jump(.sys_clk(sys_clk), .target(jump_freq), .sound(jump_out));

// === CHARGE 音效（快速漸升） ===
reg [31:0] charge_freq = C4;
reg [23:0] charge_cnt = 0;
reg charge_active = 0;
reg charge_down = 1;  // 1: 往下滑；0: 往上滑

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n || win_playing) begin
        charge_active <= 0;
        charge_cnt <= 0;
        charge_freq <= C4;
        charge_down <= 1;
    end else if (is_charge) begin
        charge_active <= 1;
        charge_cnt <= charge_cnt + 1;
        if (charge_cnt >= 1000000) begin  // 每 1ms 更新一次
            charge_cnt <= 0;
            if (charge_down) begin
                if (charge_freq > 80000)
                    charge_freq <= charge_freq - 3000;
                else
                    charge_down <= 0;  // 到底轉上升
            end else begin
                if (charge_freq < C4)
                    charge_freq <= charge_freq + 3000;
                else
                    charge_down <= 1;  // 到頂轉下降
            end
        end
    end else begin
        charge_active <= 0;
        charge_cnt <= 0;
        charge_freq <= C4;
        charge_down <= 1;
    end
end

wire [31:0] charge_target = (charge_active) ? charge_freq : REST;
wire charge_raw;
timer t_charge(.sys_clk(sys_clk), .target(charge_target), .sound(charge_raw));
wire charge_out = charge_raw;



// === HIT 音效：E -> C 雙音 ===
reg [1:0] hit_state = 0;
reg [23:0] hit_timer = 0;
parameter HIT_NOTE_DURATION = 10000000;
reg [31:0] hit_freq;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n || win_playing) begin
        hit_state <= 0;
        hit_timer <= 0;
        hit_freq <= REST;
    end else begin
        case (hit_state)
            0: if (is_hit) begin hit_freq <= 32'd151686; hit_timer <= 0; hit_state <= 1; end
            1: begin
                hit_timer <= hit_timer + 1;
                if (hit_timer >= HIT_NOTE_DURATION) begin hit_freq <= 32'd191113; hit_timer <= 0; hit_state <= 2; end
                if (is_hit) begin hit_freq <= 32'd151686; hit_timer <= 0; hit_state <= 1; end
            end
            2: begin
                hit_timer <= hit_timer + 1;
                if (hit_timer >= HIT_NOTE_DURATION) begin hit_freq <= REST; hit_state <= 0; end
                if (is_hit) begin hit_freq <= 32'd151686; hit_timer <= 0; hit_state <= 1; end
            end
        endcase
    end
end
wire hit_out;
timer t_hit(.sys_clk(sys_clk), .target(hit_freq), .sound(hit_out));

// === OUTPUT 優先順序 ===
assign melody_out = win_playing ? win_melody_out :
                    (hit_state != 0) ? hit_out :
                    is_jump ? jump_out :
                    is_charge ? charge_out :
                    1'b0;

assign bass_out = win_playing ? win_bass_out : 1'b0;

endmodule


module timer(
    input sys_clk,
    input [31:0] target,
    output wire sound
);
    reg [31:0] cnt = 0;
    reg enable = 0;
    reg [31:0] prev_target = 0;

    always @(posedge sys_clk) begin
        if (target == 32'hFFFF_FFFF) begin
            enable <= 0;
            cnt <= 0;
        end else if (target != prev_target) begin
            enable <= 1;
            cnt <= 0;
        end else if (cnt == target) begin
            cnt <= 0;
            enable <= ~enable;
        end else begin
            cnt <= cnt + 1;
        end
        prev_target <= target;
    end

    wire pwm_out;
    pwm_audio pwm_inst(.sys_clk(sys_clk), .volume(8'd240), .pwm_out(pwm_out));
    assign sound = enable ? pwm_out : 0;
endmodule

module pwm_audio(
    input sys_clk,
    input [7:0] volume,
    output pwm_out
);
    reg [7:0] pwm_cnt = 0;
    always @(posedge sys_clk) begin
        pwm_cnt <= pwm_cnt + 1;
    end
    assign pwm_out = (pwm_cnt < volume) ? 1 : 0;
endmodule

