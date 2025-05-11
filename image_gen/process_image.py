from PIL import Image
import sys
import os

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

def to_12bit(rgb):
    r, g, b = rgb
    return (r >> 4, g >> 4, b >> 4)

def rgb12_to_hexstr(r12, g12, b12):
    return f"{r12:X}{g12:X}{b12:X}"

def color_distance(c1, c2):
    return sum((a - b) ** 2 for a, b in zip(c1, c2))

def process_image(image_path, grid_cols, grid_rows):
    try:
        img = Image.open(image_path).convert('RGB')
    except Exception as e:
        print(f"Error opening image: {e}")
        sys.exit(1)

    pixels = img.load()
    img_width, img_height = img.size

    cell_width = img_width // grid_cols
    cell_height = img_height // grid_rows

    color_list = []
    color_map = {}
    color_counter = 0
    known_colors = []

    for row in range(grid_rows):
        for col in range(grid_cols):
            x0 = col * cell_width
            y0 = row * cell_height

            avg_rgb = avg_color(pixels, x0, y0, cell_width, cell_height, img_width, img_height)
            rgb12 = to_12bit(avg_rgb)

            if len(known_colors) < 10:
                if rgb12 not in color_map:
                    identifier = f"COLOR_{color_counter}"
                    color_map[rgb12] = identifier
                    known_colors.append(rgb12)
                    color_counter += 1
            else:
                best_match = min(known_colors, key=lambda c: color_distance(rgb12, c))
                rgb12 = best_match

            color_list.append(color_map[rgb12])

    return color_map, color_list

def export_verilog(color_map, color_list, grid_cols, grid_rows, output_filename, module_name):
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

        # Parameters for colors
        for rgb12, identifier in color_map.items():
            r12, g12, b12 = rgb12
            hex_color = rgb12_to_hexstr(r12, g12, b12)
            f.write(f"parameter {identifier} = 12'h{hex_color};\n")
        f.write("\n")

        # Pixel map
        f.write(f"(* rom_style = \"block\" *) reg [CHAR_WIDTH_X * CHAR_WIDTH_Y * PIXEL_WIDTH - 1:0] pixel_map = {{\n")

        for idx, color in enumerate(color_list):
            if idx % grid_cols == 0 and idx != 0:
                f.write("\n")
            if idx == len(color_list) - 1:
                f.write(f"    {color}\n")  # 最後一個沒有逗號
            else:
                f.write(f"    {color}, ")

        f.write("\n};\n\n")

        # 這是新增的 assign rgb
        f.write("assign rgb = (char_on) ? pixel_map[char_y_rom * CHAR_WIDTH_X + char_x_rom] : 12'hFFF;\n\n")

        f.write("endmodule\n")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python process_image.py <image_path> <grid_cols> <grid_rows>")
        sys.exit(1)

    image_path = sys.argv[1]
    grid_cols = int(sys.argv[2])
    grid_rows = int(sys.argv[3])

    color_map, color_list = process_image(image_path, grid_cols, grid_rows)

    base_name = os.path.splitext(os.path.basename(image_path))[0]
    module_name = base_name.upper() + "_CHAR"
    output_filename = base_name + ".v"

    export_verilog(color_map, color_list, grid_cols, grid_rows, output_filename, module_name)

    print(f"Verilog file '{output_filename}' generated successfully!")
