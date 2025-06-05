## Overview

## Project Structure

This Final Project is organized into three main folders for development purposes: `main`, `vga_test`, and `image_gen`.

---

### main/  
Contains the core game logic and all major Verilog modules, including:  
- Top-level integration  
- VGA signal generation  
- Character movement and input handling  
- Obstacle generation  
- Sound generation  

This folder also includes the `.xdc` constraint file for FPGA pin assignments.

---

### vga_test/  
Used during development to test and debug individual small modules, especially VGA output.  
Includes test modules and testbenches for validating functionality visually or through simulation.

---

### image_gen/  
Uses Python scripts to generate RAM-based Verilog modules for character rendering. Each `.v` file contains pixel data representing a specific character display state or obstacle.  
These modules are used by the VGA rendering logic to display graphics on the screen.

```
.
├── Main
│   ├── Camera.v
│   ├── Character.v
│   ├── Character_image
│   │   ├── Charging.png
│   │   ├── Fall_heavily_to_the_ground.png
│   │   ├── Falling.png
│   │   ├── IDLE.png
│   │   ├── Jump.png
│   │   ├── Landing.png
│   │   └── Safe_landing.png
│   ├── Debug_var.v
│   ├── Digit_Font_ROM.v
│   ├── Game.v
│   ├── Map.v
│   ├── Simple_Screen.xlsx
│   ├── bin_to_bcd.v
│   ├── frequency_divider.v
│   ├── tb_chracter.v
│   ├── top_module.xdc
│   └── vga_color_sel.v
├── image_gen
│   ├── CHARGE.png
│   ├── FALL_TO_GROUND.png
│   ├── IDLE_1.png
│   ├── IDLE_2.png
│   ├── JUMP_DOWN.png
│   ├── JUMP_UP.png
│   ├── SAFE_GROUND.png
│   ├── WALL_1.png
│   ├── WALL_2.png
│   ├── WALL_3.png
│   ├── WALL_4.png
│   ├── alphabet.txt
│   ├── brick_wall.xlsx
│   ├── color_char.txt
│   ├── color_obstacle.txt
│   ├── input_string.txt
│   ├── process_image_char.py
│   ├── process_image_obstacle.py
│   ├── string_to_decode.py
│   └── tb_process_image.py
├── vga_test
│   ├── IDLE.v
│   ├── Map.v
│   ├── Setup_Time_Violation.xlsx
│   ├── block_gen.v
│   ├── character_display.v
│   ├── debounce.v
│   ├── debug_var.v
│   ├── fq_div.v
│   ├── pixel_gen.v
│   ├── tb.xdc
│   ├── tb_character.v
│   ├── tb_tb_char.v
│   ├── top.v
│   ├── vga_controller.v
│   ├── vga_controller_test.v
│   └── vga_test_test
│       ├── CHARGE_CHAR.v
│       ├── FALL_TO_GROUND_CHAR.v
│       ├── IDLE_1_CHAR.v
│       ├── IDLE_2_CHAR.v
│       ├── JUMP_DOWN_CHAR.v
│       ├── JUMP_UP_CHAR.v
│       ├── Map.v
│       ├── N_decoder.v
│       ├── SAFE_GROUND_CHAR.v
│       ├── WALL_1.v
│       ├── WALL_2.v
│       ├── WALL_3.v
│       ├── WALL_4.v
│       ├── ascii_seq_display_controller.v
│       ├── bcd_seq_display_controller.v
│       ├── block_gen.v
│       ├── character_display_controller.v
│       ├── debounce.v
│       ├── debug_var.v
│       ├── display_string_rom.v
│       ├── fq_div.v
│       ├── obstacle_display_controller.v
│       ├── pixel_gen.v
│       ├── tb.xdc
│       ├── tb_tb_vga.v
│       ├── top.v
│       └── vga_controller.v
└── README.md
```

## Contributions

- **113511239**  
  - Wrote the final project report  
  - Filmed the gameplay introduction video

- **113511128**  
  - Created character sound effects and background music  
  - Edited the gameplay introduction video

- **113511270**  
  - Designed and implemented character movement logic  
  - Created game visuals including obstacles and backgrounds

## Final Result

🎬 **Gameplay Demo:** [Watch on YouTube](https://youtu.be/zS32HuutKGs)
