
from PIL import Image
import sys
import os

# 平均顏色取樣
def avg_color(pixels, x0, y0, cell_width, cell_height, img_width, img_height):
    r_total = g_total = b_total = count = 0
    for y in range(y0, min(y0 + cell_height, img_height)):
        for x in range(x0, min(x0 + cell_width, img_width)):
            r, g, b = pixels[x, y]
            r_total += r
            g_total += g
            b_total += b
            count += 1
    return (r_total // count, g_total // count, b_total // count)

# 將 RGB 壓縮成 12-bit（每個通道 4-bit）
def rgb24_to_rgb12(r, g, b):
    return (r >> 4, g >> 4, b >> 4)

# 將 12-bit RGB 轉為 HEX 字串格式
def rgb12_to_hexstr(r12, g12, b12):
    return f"{b12:X}{g12:X}{r12:X}"

# 計算顏色距離（24-bit 空間下）
def color_distance(c1, c2):
    return sum((a - b) ** 2 for a, b in zip(c1, c2))

# 從 color.txt 載入預設調色盤
def load_palette_from_file(file_path):
    palette = []
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) >= 3:
                try:
                    r = int(float(parts[0]))
                    g = int(float(parts[1]))
                    b = int(float(parts[2]))
                    palette.append((r, g, b))
                except ValueError:
                    continue
    return palette

# 主圖片處理函數（回傳：每格顏色對應的索引，以及 palette 對應的 rgb12）
def process_image(image_path, grid_cols, grid_rows, palette_path):
    img = Image.open(image_path).convert('RGB')
    pixels = img.load()
    img_width, img_height = img.size

    cell_width = img_width // grid_cols
    cell_height = img_height // grid_rows

    palette = load_palette_from_file(palette_path)
    color_indices = []

    for row in range(grid_rows):
        for col in range(grid_cols):
            x0 = col * cell_width
            y0 = row * cell_height
            avg_rgb = avg_color(pixels, x0, y0, cell_width, cell_height, img_width, img_height)
            best_match_idx = min(range(len(palette)), key=lambda i: color_distance(avg_rgb, palette[i]))
            color_indices.append(best_match_idx)

    palette_rgb12 = [rgb24_to_rgb12(*color) for color in palette]
    return color_indices, palette_rgb12

# Verilog 匯出函數（以 color index 輸出）
def export_verilog(color_indices, palette_rgb12, grid_cols, grid_rows, output_filename, module_name):
    with open(output_filename, 'w') as f:
        f.write("// Auto-generated Verilog pixel data (12-bit RGB)\n")
        f.write(f"module {module_name} #(\n")
        f.write("    parameter COLOR_WIDTH = 2,\n")
        f.write("    parameter SCREEN_WIDTH = 10\n")
        f.write(") (\n")
        f.write("    input sys_clk,\n")
        f.write("    input sys_rst_n,\n")
        f.write("    input [SCREEN_WIDTH - 1:0] obstacle_x_rom,\n")
        f.write("    input [SCREEN_WIDTH - 1:0] obstacle_y_rom,\n")
        f.write("    input obstacle_on,\n")
        f.write("    output reg [COLOR_WIDTH - 1:0] rgb_id\n")
        f.write(");\n\n")

        for idx, (r12, g12, b12) in enumerate(palette_rgb12):
            hex_color = rgb12_to_hexstr(r12, g12, b12)
            f.write(f"// {idx} for 12'h{hex_color};\n")
        f.write("\n")
        
        f.write(f"localparam OBSTACLE_WIDTH_X = {grid_cols};\n")
        f.write(f"localparam OBSTACLE_WIDTH_Y = {grid_rows};\n")

        f.write(f"(* rom_style = \"block\" *) reg [OBSTACLE_WIDTH_X * OBSTACLE_WIDTH_Y * COLOR_WIDTH - 1:0] pixel_map = {{\n")
        for idx, color_idx in enumerate(color_indices):
            if idx % grid_cols == 0 and idx != 0:
                f.write("\n")
            if idx == len(color_indices) - 1:
                f.write(f"    2'b{color_idx:02b}\n")
            else:
                f.write(f"    2'b{color_idx:02b}, ")

        f.write("\n};\n\n")

        f.write("always @(posedge sys_clk or negedge sys_rst_n) begin\n")
        f.write("    if (!sys_rst_n) begin\n")
        f.write("        rgb_id <= 2'b10; // default color : black \n")
        f.write("    end else if (obstacle_on) begin\n")
        f.write("        rgb_id <= pixel_map[(obstacle_y_rom * OBSTACLE_WIDTH_X + obstacle_x_rom) * COLOR_WIDTH +: COLOR_WIDTH];\n")
        f.write("    end else begin\n")
        f.write("        rgb_id <= 2'b10; // default color : black \n")
        f.write("    end\n")
        f.write("end\n")
        f.write("endmodule\n")

# 主程式
if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python process_image.py <image_path> <grid_cols> <grid_rows>")
        sys.exit(1)

    image_path = sys.argv[1]
    grid_cols = int(sys.argv[2])
    grid_rows = int(sys.argv[3])
    palette_path = r"C:\Users\user\Desktop\DLAB\Final_Project_source_code\image_gen\color_obstacle.txt"

    color_indices, palette_rgb12 = process_image(image_path, grid_cols, grid_rows, palette_path)

    base_name = os.path.splitext(os.path.basename(image_path))[0]
    module_name = base_name.upper()
    output_filename = base_name + ".v"

    export_verilog(color_indices, palette_rgb12, grid_cols, grid_rows, output_filename, module_name)
    print(f"Verilog file '{output_filename}' generated successfully!")
