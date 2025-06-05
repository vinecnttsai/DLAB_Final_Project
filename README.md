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
├── Main/
├── image_gen/
├── vga_test/
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

## Logs

- [Bug Log](https://www.youtube.com/playlist?list=PLpxorNaCaWOXqAmyeMm6AM1oebjU1_c_p)  
- [Development Log](https://www.youtube.com/playlist?list=PLpxorNaCaWOWvo9MXOh9dHbYsydglwqYU)

## Final Result

- [Gameplay Demo](https://youtu.be/zS32HuutKGs)
