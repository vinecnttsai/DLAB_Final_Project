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

# 主圖片處理函數
def process_image(image_path, grid_cols, grid_rows, palette_path):
    img = Image.open(image_path).convert('RGB')
    pixels = img.load()
    img_width, img_height = img.size

    cell_width = img_width // grid_cols
    cell_height = img_height // grid_rows

    # 載入 palette 並轉成 12-bit 格式
    palette = load_palette_from_file(palette_path)
    palette_rgb12 = [rgb24_to_rgb12(*color) for color in palette]

    color_list = []
    rgb12_to_identifier = {}
    identifier_to_rgb12 = {}

    for idx, rgb12 in enumerate(palette_rgb12):
        identifier = f"C_{idx}"
        rgb12_to_identifier[rgb12] = identifier
        identifier_to_rgb12[identifier] = rgb12

    for row in range(grid_rows):
        for col in range(grid_cols):
            x0 = col * cell_width
            y0 = row * cell_height
            avg_rgb = avg_color(pixels, x0, y0, cell_width, cell_height, img_width, img_height)

            # 找出最接近的 palette 顏色
            best_match_idx = min(range(len(palette)), key=lambda i: color_distance(avg_rgb, palette[i]))
            matched_rgb12 = palette_rgb12[best_match_idx]
            identifier = rgb12_to_identifier[matched_rgb12]
            color_list.append(identifier)

    return rgb12_to_identifier, color_list, identifier_to_rgb12

# Verilog 匯出函數
def export_verilog(color_map, color_list, id_to_rgb12, grid_cols, grid_rows, output_filename, module_name):
    with open(output_filename, 'w') as f:
        f.write("// Auto-generated Verilog pixel data (12-bit RGB)\n")
        f.write(f"module {module_name} #(\n")
        f.write("    parameter PIXEL_WIDTH = 12,\n")
        f.write("    parameter SCREEN_WIDTH = 10,\n")
        f.write(f"    parameter CHAR_WIDTH_X = {grid_cols},\n")
        f.write(f"    parameter CHAR_WIDTH_Y = {grid_rows}\n")
        f.write(") (\n")
        f.write("    input [SCREEN_WIDTH - 1:0] char_x_rom,\n")
        f.write("    input [SCREEN_WIDTH - 1:0] char_y_rom,\n")
        f.write("    input char_on,\n")
        f.write("    output [PIXEL_WIDTH - 1:0] rgb\n")
        f.write(");\n\n")

        for identifier in sorted(id_to_rgb12.keys(), key=lambda x: int(x.split('_')[1])):
            r12, g12, b12 = id_to_rgb12[identifier]
            hex_color = rgb12_to_hexstr(r12, g12, b12)
            f.write(f"parameter {identifier} = 12'h{hex_color};\n")
        f.write("\n")

        f.write(f"(* rom_style = \"block\" *) reg [CHAR_WIDTH_X * CHAR_WIDTH_Y * PIXEL_WIDTH - 1:0] pixel_map = {{\n")
        for idx, color in enumerate(color_list):
            if idx % grid_cols == 0 and idx != 0:
                f.write("\n")
            if idx == len(color_list) - 1:
                f.write(f"    {color}\n")
            else:
                f.write(f"    {color}, ")
        f.write("\n};\n\n")

        f.write("assign rgb = pixel_map[(char_y_rom * CHAR_WIDTH_X + char_x_rom) * PIXEL_WIDTH +: PIXEL_WIDTH];\n\n")
        f.write("endmodule\n")

# 主程式
if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python process_image.py <image_path> <grid_cols> <grid_rows>")
        sys.exit(1)

    image_path = sys.argv[1]
    grid_cols = int(sys.argv[2])
    grid_rows = int(sys.argv[3])
    palette_path = r"C:\Users\user\Desktop\DLAB\Final_Project_source_code\image_gen\color.txt"

    color_map, color_list, id_to_rgb12 = process_image(image_path, grid_cols, grid_rows, palette_path)

    base_name = os.path.splitext(os.path.basename(image_path))[0]
    module_name = base_name.upper() + "_CHAR"
    output_filename = base_name + "_CHAR.v"

    export_verilog(color_map, color_list, id_to_rgb12, grid_cols, grid_rows, output_filename, module_name)
    print(f"Verilog file '{output_filename}' generated successfully!")