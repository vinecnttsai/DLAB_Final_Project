module mario_music(
    input sys_clk,
    input sys_rst_n,
    output melody_out,
    output bass_out
);

// Note frequency dividers (based on 100MHz clock)
parameter C3 = 382225, D3 = 340524, E3 = 303372, F3 = 286344;
parameter G3 = 255102, A3 = 227272, B3 = 202478;
parameter C4 = 191113, D4 = 170262, E4 = 151686, F4 = 143173;
parameter G4 = 127551, A4 = 113636, B4 = 101239, C5 = 95556;
parameter D5 = 85131,  E5 = 75843,  F5 = 71586,  G5 = 63776, A5 = 56818;
parameter Bb4 = 107258, Gs4 = 120327, Fs5 = 67568, Ds5 = 80384;
parameter Eb5 = 80384, C6 = 47750;
parameter REST = 32'hFFFF_FFFF;
parameter G2 = 510204;
parameter Gb3 = 321414;
parameter Ab3 = 240790;
parameter Bb3 = 214518;

parameter BEAT = 20000000;

// note arrays
reg [31:0] melody_notes [0:111];
reg [31:0] bass_notes [0:111];

reg [6:0] idx = 0;
reg [31:0] beat_counter = 0;
reg [31:0] current_note;
reg [31:0] current_bass;
wire melody_tone, bass_tone;

// repeat control
reg repeated_loop1 = 0;

// segment definitions
localparam LOOP1_START = 16, LOOP1_END = 47;


initial begin
    // Melody (同前)
    melody_notes[0]=E5; melody_notes[1]=E5; melody_notes[2]=REST; melody_notes[3]=E5;
    melody_notes[4]=REST; melody_notes[5]=C5; melody_notes[6]=E5; melody_notes[7]=E5;
    melody_notes[8]=G5; melody_notes[9]=G5; melody_notes[10]=REST; melody_notes[11]=REST;
    melody_notes[12]=G4; melody_notes[13]=G4; melody_notes[14]=REST; melody_notes[15]=REST;
    melody_notes[16]=C5; melody_notes[17]=C5; melody_notes[18]=REST; melody_notes[19]=G4;
    melody_notes[20]=G4; melody_notes[21]=REST; melody_notes[22]=E4; melody_notes[23]=E4;
    melody_notes[24]=REST; melody_notes[25]=A4; melody_notes[26]=A4; melody_notes[27]=B4;
    melody_notes[28]=B4; melody_notes[29]=Bb4; melody_notes[30]=A4; melody_notes[31]=A4;
    melody_notes[32]=G4; melody_notes[33]=E5; melody_notes[34]=E5; melody_notes[35]=G5;
    melody_notes[36]=A5; melody_notes[37]=A5; melody_notes[38]=F5; melody_notes[39]=G5;
    melody_notes[40]=REST; melody_notes[41]=E5; melody_notes[42]=E5; melody_notes[43]=C5;
    melody_notes[44]=D5; melody_notes[45]=B4; melody_notes[46]=B4; melody_notes[47]=REST;
    melody_notes[48]=REST; melody_notes[49]=REST; melody_notes[50]=G5; melody_notes[51]=Fs5;
    melody_notes[52]=F5; melody_notes[53]=Ds5; melody_notes[54]=Ds5; melody_notes[55]=E5;
    melody_notes[56]=REST; melody_notes[57]=Gs4; melody_notes[58]=A4; melody_notes[59]=C5;
    melody_notes[60]=REST; melody_notes[61]=A4; melody_notes[62]=C5; melody_notes[63]=D5;
    melody_notes[64]=REST; melody_notes[65]=REST; melody_notes[66]=G5; melody_notes[67]=Fs5;
    melody_notes[68]=G5; melody_notes[69]=REST; melody_notes[70]=REST; melody_notes[71]=G4;
    melody_notes[72]=REST; melody_notes[73]=C6; melody_notes[74]=C6; melody_notes[75]=C6;
    melody_notes[76]=C6; melody_notes[77]=C6; melody_notes[78]=REST; melody_notes[79]=REST;
    melody_notes[80]=REST; melody_notes[81]=REST; melody_notes[82]=G5; melody_notes[83]=Fs5;
    melody_notes[84]=F5; melody_notes[85]=Ds5; melody_notes[86]=Ds5; melody_notes[87]=E5;
    melody_notes[88]=REST; melody_notes[89]=Gs4; melody_notes[90]=A4; melody_notes[91]=C5;
    melody_notes[92]=REST; melody_notes[93]=A4; melody_notes[94]=C5; melody_notes[95]=D5;
    melody_notes[96]=REST; melody_notes[97]=REST; melody_notes[98]=Eb5; melody_notes[99]=Eb5;
    melody_notes[100]=REST; melody_notes[101]=D5; melody_notes[102]=D5; melody_notes[103]=REST;
    melody_notes[104]=C5; melody_notes[105]=C5; melody_notes[106]=REST; melody_notes[107]=REST;
    melody_notes[108]=REST; melody_notes[109]=REST; melody_notes[110]=REST; melody_notes[111]=REST;

    // Bass
    bass_notes[0]=D3; bass_notes[1]=D3; bass_notes[2]=REST; bass_notes[3]=D3;
    bass_notes[4]=REST; bass_notes[5]=D3; bass_notes[6]=D3; bass_notes[7]=D3;
    
    bass_notes[8]=G3; bass_notes[9]=G3; bass_notes[10]=REST; bass_notes[11]=REST;
    bass_notes[12]=G2; bass_notes[13]=G2; bass_notes[14]=REST; bass_notes[15]=REST;
    
    bass_notes[16]=G3; bass_notes[17]=G3; bass_notes[18]=REST; bass_notes[19]=E3;
    bass_notes[20]=E3; bass_notes[21]=REST; bass_notes[22]=C3; bass_notes[23]=C3;
    
    bass_notes[24]=REST; bass_notes[25]=F3; bass_notes[26]=F3; bass_notes[27]=G3;
    bass_notes[28]=G3; bass_notes[29]=Gb3; bass_notes[30]=F3; bass_notes[31]=F3;
    
    bass_notes[32]=E3; bass_notes[33]=C4; bass_notes[34]=C4; bass_notes[35]=E4;
    bass_notes[36]=F4; bass_notes[37]=F4; bass_notes[38]=D4; bass_notes[39]=E4;
    
    bass_notes[40]=REST; bass_notes[41]=C4; bass_notes[42]=C4; bass_notes[43]=A3;
    bass_notes[44]=B3; bass_notes[45]=G3; bass_notes[46]=G3; bass_notes[47]=REST;
    
    bass_notes[48]=C3; bass_notes[49]=C3; bass_notes[50]=REST; bass_notes[51]=G3;
    bass_notes[52]=REST; bass_notes[53]=REST; bass_notes[54]=C4; bass_notes[55]=C4;
    
    bass_notes[56]=F3; bass_notes[57]=F3; bass_notes[58]=REST; bass_notes[59]=C4;
    bass_notes[60]=C4; bass_notes[61]=C4; bass_notes[62]=F3; bass_notes[63]=F3;
    
    bass_notes[64]=C3; bass_notes[65]=C3; bass_notes[66]=REST; bass_notes[67]=G3;
    bass_notes[68]=REST; bass_notes[69]=REST; bass_notes[70]=G3; bass_notes[71]=C4;
    
    bass_notes[72]=REST; bass_notes[73]=G4; bass_notes[74]=G4; bass_notes[75]=G4;
    bass_notes[76]=G4; bass_notes[77]=G4; bass_notes[78]=G3; bass_notes[79]=G3;
    
    bass_notes[80]=C3; bass_notes[81]=C3; bass_notes[82]=REST; bass_notes[83]=G3;
    bass_notes[84]=REST; bass_notes[85]=REST; bass_notes[86]=C4; bass_notes[87]=C4;
    
    bass_notes[88]=F3; bass_notes[89]=F3; bass_notes[90]=REST; bass_notes[91]=C4;
    bass_notes[92]=C4; bass_notes[93]=C4; bass_notes[94]=F3; bass_notes[95]=F3;
    
    bass_notes[96]=C3; bass_notes[97]=C3; bass_notes[98]=Ab3; bass_notes[99]=Ab3;
    bass_notes[100]=REST; bass_notes[101]=Bb3; bass_notes[102]=Bb3; bass_notes[103]=REST;
    
    bass_notes[104]=C4; bass_notes[105]=C4; bass_notes[106]=REST; bass_notes[107]=G3;
    bass_notes[108]=G3; bass_notes[109]=G3; bass_notes[110]=C3; bass_notes[111]=C3;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        idx <= 0;
        beat_counter <= 0;
        current_note <= melody_notes[0];
        current_bass <= bass_notes[0];
        repeated_loop1 <= 0;
    end else begin
        if (beat_counter >= BEAT) begin
            beat_counter <= 0;

            if (idx == LOOP1_END && repeated_loop1 == 0) begin
                idx <= LOOP1_START;  // repeat 2~6小節
                repeated_loop1 <= 1;
            end else if (idx == 111) begin
                idx <= 0;
                repeated_loop1 <= 0;
            end else begin
                idx <= idx + 1;
            end
        end else begin
            beat_counter <= beat_counter + 1;
        end

        current_note <= melody_notes[idx];
        current_bass <= bass_notes[idx];
    end
end

timer tone1(sys_clk, current_note, melody_tone);
timer tone2(sys_clk, current_bass, bass_tone);
assign melody_out = melody_tone;
assign bass_out = bass_tone;

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
    pwm_audio pwm_inst(sys_clk, 8'd240, pwm_out);
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