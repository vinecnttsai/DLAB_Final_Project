module vga_color_selector (
    input  [3:0] color_sel,      // �C���� (0~8)
    input  [7:0] white_ratio,    // �[�զ��� (0~255)
    output [15:0] vga_data       // VGA 16bit RGB565��X
);

    // ��l�C�� (8bit)
    reg [7:0] base_r, base_g, base_b;

    always @(*) begin
        case (color_sel)
            4'd0: {base_r, base_g, base_b} = {8'd0,   8'd0,   8'd0};   // �¦�
            4'd1: {base_r, base_g, base_b} = {8'd255, 8'd255, 8'd255}; // �զ�
            4'd2: {base_r, base_g, base_b} = {8'd255, 8'd0,   8'd0};   // ����
            4'd3: {base_r, base_g, base_b} = {8'd0,   8'd255, 8'd0};   // ���
            4'd4: {base_r, base_g, base_b} = {8'd0,   8'd0,   8'd255}; // �Ŧ�
            4'd5: {base_r, base_g, base_b} = {8'd255, 8'd255, 8'd0};   // ����
            4'd6: {base_r, base_g, base_b} = {8'd0,   8'd255, 8'd255}; // �C��
            4'd7: {base_r, base_g, base_b} = {8'd255, 8'd0,   8'd255}; // �~��
            4'd8: {base_r, base_g, base_b} = {8'd128, 8'd128, 8'd128}; // �Ǧ�
            default: {base_r, base_g, base_b} = {8'd0, 8'd0, 8'd0};    // �w�]�¦�
        endcase
    end

    // �[�զ⪺�V��B�� (�u�ʴ���)
    wire [15:0] mix_r, mix_g, mix_b;

    assign mix_r = ((base_r * (8'd255 - white_ratio)) + (white_ratio * 8'd255)) >> 8;
    assign mix_g = ((base_g * (8'd255 - white_ratio)) + (white_ratio * 8'd255)) >> 8;
    assign mix_b = ((base_b * (8'd255 - white_ratio)) + (white_ratio * 8'd255)) >> 8;

    // �Y�� VGA 5:6:5�榡
    wire [4:0] vga_r = mix_r[7:3]; // 8bit -> 5bit (������)
    wire [5:0] vga_g = mix_g[7:2]; // 8bit -> 6bit
    wire [4:0] vga_b = mix_b[7:3]; // 8bit -> 5bit

    // �զ�16bit��X (RGB565�榡)
    assign vga_data = {vga_r, vga_g, vga_b};
    // vga_data[15:11] = R (5bit)
    // vga_data[10:5]  = G (6bit)
    // vga_data[4:0]   = B (5bit)

endmodule
