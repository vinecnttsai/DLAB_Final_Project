module vga_color_selector (
    input  [3:0] color_sel,      // 顏色選擇 (0~8)
    input  [7:0] white_ratio,    // 加白色比例 (0~255)
    output [15:0] vga_data       // VGA 16bit RGB565輸出
);

    // 原始顏色 (8bit)
    reg [7:0] base_r, base_g, base_b;

    always @(*) begin
        case (color_sel)
            4'd0: {base_r, base_g, base_b} = {8'd0,   8'd0,   8'd0};   // 黑色
            4'd1: {base_r, base_g, base_b} = {8'd255, 8'd255, 8'd255}; // 白色
            4'd2: {base_r, base_g, base_b} = {8'd255, 8'd0,   8'd0};   // 紅色
            4'd3: {base_r, base_g, base_b} = {8'd0,   8'd255, 8'd0};   // 綠色
            4'd4: {base_r, base_g, base_b} = {8'd0,   8'd0,   8'd255}; // 藍色
            4'd5: {base_r, base_g, base_b} = {8'd255, 8'd255, 8'd0};   // 黃色
            4'd6: {base_r, base_g, base_b} = {8'd0,   8'd255, 8'd255}; // 青色
            4'd7: {base_r, base_g, base_b} = {8'd255, 8'd0,   8'd255}; // 品紅
            4'd8: {base_r, base_g, base_b} = {8'd128, 8'd128, 8'd128}; // 灰色
            default: {base_r, base_g, base_b} = {8'd0, 8'd0, 8'd0};    // 預設黑色
        endcase
    end

    // 加白色的混色運算 (線性插值)
    wire [15:0] mix_r, mix_g, mix_b;

    assign mix_r = ((base_r * (8'd255 - white_ratio)) + (white_ratio * 8'd255)) >> 8;
    assign mix_g = ((base_g * (8'd255 - white_ratio)) + (white_ratio * 8'd255)) >> 8;
    assign mix_b = ((base_b * (8'd255 - white_ratio)) + (white_ratio * 8'd255)) >> 8;

    // 縮到 VGA 5:6:5格式
    wire [4:0] vga_r = mix_r[7:3]; // 8bit -> 5bit (取高位)
    wire [5:0] vga_g = mix_g[7:2]; // 8bit -> 6bit
    wire [4:0] vga_b = mix_b[7:3]; // 8bit -> 5bit

    // 組成16bit輸出 (RGB565格式)
    assign vga_data = {vga_r, vga_g, vga_b};
    // vga_data[15:11] = R (5bit)
    // vga_data[10:5]  = G (6bit)
    // vga_data[4:0]   = B (5bit)

endmodule
