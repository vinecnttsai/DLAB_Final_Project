## Overview

This is a Verilog-based implementation of an **"Only Up"-style 2D pixel art game**.  
The project features a vertical-scrolling gameplay mechanic, where the player controls a character navigating upward through obstacles.  
The design is targeted for FPGA deployment with VGA display output.

---

## Repository Structure

project-root/
│
├── main/
│ └── Contains the core logic of the project. All Verilog source files (.v) and constraint files (.xdc) are located here.
│ This includes the top-level module, FSM, VGA controller, collision detection, and game logic.
│
├── vga_test/
│ └── Used during development to test individual components or features in isolation.
│ Includes simple testbenches and test modules for debugging VGA output and other subsystems.
│
└── image_gen/
└── Contains Verilog modules for RAM initialization to store pixel data for sprites. This includes:
- Character sprites in different animation states
- Obstacle graphics and other game elements
Each module here defines the memory structure used to render pixel-based graphics in the game

## Contributions

- **Alice**  
  - Wrote the final project report  
  - Filmed the gameplay introduction video

- **Bob**  
  - Created character sound effects and background music  
  - Edited the gameplay introduction video

- **Charlie**  
  - Designed and implemented character movement logic  
  - Created game visuals including obstacles and backgrounds

## Final Result

🎬 **Gameplay Demo:** [Watch on YouTube](https://youtu.be/zS32HuutKGs)
