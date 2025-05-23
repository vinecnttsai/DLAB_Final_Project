def read_alphabet_mapping():
    """Read the alphabet mapping from alphabet.txt"""
    mapping = {}
    with open('C:/Users/user/Desktop/DLAB/Final_Project_source_code/image_gen/alphabet.txt', 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) == 2:
                char, value = parts

                # 將 @ 視為空白字元
                if char == '@':
                    char = ' '

                if "'d" in value:
                    mapping[char] = value.split("'d")[1]

    print(mapping)
    return mapping

def convert_strings_to_verilog_module(input_file, output_file):
    MAX_CHAR = 11
    mapping = read_alphabet_mapping()
    space_value = mapping.get(' ')
    if space_value is None:
        raise ValueError("Space character (' ') not found in alphabet.txt.")

    with open(input_file, 'r') as f:
        input_strings = [line.rstrip() for line in f if line.rstrip()]

    num_strings = len(input_strings)

    verilog_code = f"""module string_rom #(
    parameter STRING_NUM = {num_strings},
    parameter MAX_CHAR = {MAX_CHAR},
    parameter CHAR_WIDTH = 5
)
(
    input wire [$clog2(STRING_NUM + 1) - 1:0] addr,
    output reg [CHAR_WIDTH*MAX_CHAR-1:0] string_out
);

// Number of strings: {num_strings}
// Each string is MAX_CHAR characters
// Unknown characters are replaced with space (5'd{space_value})

(*rom_style = "block"*) reg [CHAR_WIDTH*MAX_CHAR*STRING_NUM-1:0] string_rom = {{
"""

    all_values = []
    for s in input_strings:
        values = [mapping.get(c, space_value) for c in s[:MAX_CHAR]]
        # 從字串尾部補空白 (右側補空白)
        while len(values) < MAX_CHAR:
            values.append(space_value)
        # 不反轉，保持原序
        all_values.extend(values)

    # 輸出時依照 MSB -> LSB 順序直接輸出，不用反轉
    for i in range(0, len(all_values), MAX_CHAR):
        if i > 0:
            verilog_code += ",\n"
        verilog_code += "    "
        verilog_code += ", ".join(f"5'd{v}" for v in all_values[i:i+MAX_CHAR])

    verilog_code += """
};

always @(*) begin
    string_out = string_rom[addr*CHAR_WIDTH*MAX_CHAR +: CHAR_WIDTH*MAX_CHAR];
end

endmodule
"""

    with open(output_file, 'w') as f:
        f.write(verilog_code)

    print(f"Conversion complete. Results written to {output_file}")




if __name__ == "__main__":
    input_file = "C:/Users/user/Desktop/DLAB/Final_Project_source_code/image_gen/input_string.txt"
    output_file = "C:/Users/user/Desktop/DLAB/Final_Project_source_code/vga_test/vga_test_test/display_string_rom.v"
    convert_strings_to_verilog_module(input_file, output_file)
