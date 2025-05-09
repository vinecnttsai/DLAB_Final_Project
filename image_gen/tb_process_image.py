from PIL import Image
import sys

def hex12_to_rgb24(hexstr):
    """Convert 12-bit RGB string (like 'ABC') to 24-bit (R,G,B) tuple"""
    r = int(hexstr[0], 16) * 17  # 0xA -> 0xAA
    g = int(hexstr[1], 16) * 17
    b = int(hexstr[2], 16) * 17
    return (r, g, b)

def reconstruct_image(pixel_map, color_map_hex, grid_cols, grid_rows, cell_size=10, output_filename="reconstructed.png"):
    # 建立新圖片
    img_width = grid_cols * cell_size
    img_height = grid_rows * cell_size
    img = Image.new("RGB", (img_width, img_height))
    pixels = img.load()

    # 先把color_map轉成 {identifier: (r,g,b)}
    color_map_rgb = {}
    for identifier, hexstr in color_map_hex.items():
        color_map_rgb[identifier] = hex12_to_rgb24(hexstr)

    for row in range(grid_rows):
        for col in range(grid_cols):
            idx = row * grid_cols + col
            identifier = pixel_map[idx]
            color = color_map_rgb[identifier]

            # 填這格（cell_size x cell_size）
            for dy in range(cell_size):
                for dx in range(cell_size):
                    x = col * cell_size + dx
                    y = row * cell_size + dy
                    pixels[x, y] = color

    img.save(output_filename)
    print(f"Image saved to {output_filename}")

if __name__ == "__main__":
    # 假設你手上有：
    # - color_map_hex: { "COLOR_0": "ABC", "COLOR_1": "DEF", ... }
    # - pixel_map: ["COLOR_0", "COLOR_1", "COLOR_1", ...]

    # 這邊先示範假資料，你可以自己從Verilog parser改過來！

    color_map_hex = {
        "COLOR_0": "F00",  # 紅
        "COLOR_1": "0F0",  # 綠
        "COLOR_2": "00F",  # 藍
    }

    pixel_map = [
        "COLOR_0", "COLOR_1", "COLOR_2",
        "COLOR_1", "COLOR_2", "COLOR_0",
        "COLOR_2", "COLOR_0", "COLOR_1",
    ]

    grid_cols = 3
    grid_rows = 3
    reconstruct_image(pixel_map, color_map_hex, grid_cols, grid_rows, cell_size=30, output_filename="reconstructed.png")
