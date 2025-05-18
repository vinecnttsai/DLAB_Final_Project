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

# 色彩精度壓縮
def to_18bit(rgb):
    r, g, b = rgb
    return (r >> 2, g >> 2, b >> 2)

def rgb18_to_rgb12(r18, g18, b18):
    return (r18 >> 2, g18 >> 2, b18 >> 2)

def rgb12_to_hexstr(r12, g12, b12):
    return f"{b12:X}{g12:X}{r12:X}"

def color_distance(c1, c2):
    return sum((a - b) ** 2 for a, b in zip(c1, c2))

# 圖片分析主函數
def process_image(image_path, grid_cols, grid_rows, max_colors=16):
    img = Image.open(image_path).convert('RGB')
    pixels = img.load()
    img_width, img_height = img.size

    cell_width = img_width // grid_cols
    cell_height = img_height // grid_rows

    color_list = []
    rgb18_to_identifier = {}
    rgb12_to_identifier = {}
    identifier_to_rgb12 = {}
    known_colors = []
    color_counter = 0

    for row in range(grid_rows):
        for col in range(grid_cols):
            x0 = col * cell_width
            y0 = row * cell_height
            avg_rgb = avg_color(pixels, x0, y0, cell_width, cell_height, img_width, img_height)
            rgb18 = to_18bit(avg_rgb)

            if len(known_colors) < max_colors:
                if rgb18 not in rgb18_to_identifier:
                    identifier = f"COLOR_{color_counter}"
                    rgb12 = rgb18_to_rgb12(*rgb18)
                    rgb18_to_identifier[rgb18] = identifier
                    rgb12_to_identifier[rgb12] = identifier
                    identifier_to_rgb12[identifier] = rgb12
                    known_colors.append(rgb18)
                    color_counter += 1
            else:
                best_match = min(known_colors, key=lambda c: color_distance(rgb18, c))
                rgb18 = best_match

            identifier = rgb18_to_identifier[rgb18]
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

# 主程式入口
if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python process_image.py <image_path> <grid_cols> <grid_rows> <max_colors>")
        sys.exit(1)

    image_path = sys.argv[1]
    grid_cols = int(sys.argv[2])
    grid_rows = int(sys.argv[3])
    max_colors = int(sys.argv[4])

    color_map, color_list, id_to_rgb12 = process_image(image_path, grid_cols, grid_rows, max_colors)

    base_name = os.path.splitext(os.path.basename(image_path))[0]
    module_name = base_name.upper() + "_CHAR"
    output_filename = base_name + "_CHAR.v"

    export_verilog(color_map, color_list, id_to_rgb12, grid_cols, grid_rows, output_filename, module_name)
    print(f"Verilog file '{output_filename}' generated successfully!")
