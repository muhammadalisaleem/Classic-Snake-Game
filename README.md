
# 🐍 Snake Game in 8086 Assembly

## 📜 Description
This project is a classic **Snake Game** implemented entirely in **8086 Assembly language** targeting the DOS environment. The game runs in text mode (80x25) and uses BIOS interrupts and direct video memory access for input handling and display output. 

Control the snake with arrow keys to eat food, grow longer, and avoid running into yourself. The game ends when the snake collides with its own body or the boundary.

---

## 🎮 Features
- Responsive real-time control using arrow keys
- Food spawning at random locations
- Score tracking and display
- Snake growth on food consumption
- Self-collision detection causing game over
- Centered title screen and gameplay UI
- Buffer-based rendering for smooth visuals

---

## 🛠 Requirements
- DOS environment or DOS emulator such as [DOSBox](https://www.dosbox.com/)
- NASM assembler to build the `.COM` executable
- Basic familiarity with running DOS programs

---

## ▶️ How to Run (Using NASM)
1. **Assemble the source code into a `.COM` executable:**
   ```bash
   nasm snakegame.asm -f bin -o snakegame.com
   ```

2. **Run the game inside DOSBox or any DOS environment:**

   ```bash
   snakegame.com
   ```

> ⚠️ Make sure your `snakegame.asm` file uses `ORG 100h` to produce a proper COM format executable.

---

## 🎮 Controls

* **Arrow Keys:** Move the snake up, down, left, or right
* **ESC:** Exit the game

---

## 📁 File Structure

| Filename        | Description                    |
| --------------- | ------------------------------ |
| `snakegame.asm` | Source code for the Snake game |
| `README.md`     | This documentation file        |

---

## 🧠 Concepts and Techniques Used

* BIOS interrupts for keyboard and display (`INT 10h`, `INT 16h`, etc.)
* Direct manipulation of video memory at segment `0xB800`
* Handling keyboard input with scan codes
* Buffer-based rendering for smooth display updates
* Simple game logic for snake movement, food generation, and collision detection
* Basic timing using BIOS time interrupts

---

## 🧩 Future Improvements

* Add sound effects via PC speaker or BIOS calls
* Implement difficulty levels with varying snake speed
* Save high scores to a file or memory
* Use colors to differentiate snake and food
* Add pause/resume functionality

---

## 📜 License

This project is released for educational purposes. Feel free to use, modify, and distribute the code with appropriate credit to the authors.

---

Thank you for trying out the Snake Game!
Feel free to contribute or report issues.

```
