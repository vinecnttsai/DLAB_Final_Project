from PIL import Image
import sys
import os
import math

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
                # 找最接近的顏色
                best_match = min(known_colors, key=lambda c: color_distance(rgb12, c))
                rgb12 = best_match

            color_list.append(color_map[rgb12])

    return color_map, color_list

def export_verilog(color_map, color_list, grid_cols, output_filename):
    with open(output_filename, 'w') as f:
        f.write("// Auto-generated Verilog pixel data (12-bit RGB)\n\n")

        for rgb12, identifier in color_map.items():
            r12, g12, b12 = rgb12
            hex_color = rgb12_to_hexstr(r12, g12, b12)
            f.write(f"parameter {identifier} = 12'h{hex_color};\n")

        f.write("\n")

        total_cells = len(color_list)
        f.write(f"reg [11:0] pixel_map [0:{total_cells-1}] = '{{\n")

        for idx, color in enumerate(color_list):
            if idx % grid_cols == 0 and idx != 0:
                f.write("\n")
            f.write(f"    {color}, ")

        f.write("\n};\n")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python process_image.py <image_path> <grid_cols> <grid_rows>")
        sys.exit(1)

    image_path = sys.argv[1]
    grid_cols = int(sys.argv[2])
    grid_rows = int(sys.argv[3])

    color_map, color_list = process_image(image_path, grid_cols, grid_rows)

    base_name = os.path.splitext(os.path.basename(image_path))[0]
    output_filename = base_name + ".v"

    export_verilog(color_map, color_list, grid_cols, output_filename)

    print(f"Verilog file '{output_filename}' generated successfully!")
