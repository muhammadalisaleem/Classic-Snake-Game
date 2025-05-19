🐍 Snake Game in 8086 Assembly
👨‍💻 Authors
Ali Saleem (23L-2638)

Ammar Hassan (23L-2614)

📜 Description
This is a classic Snake Game implemented in 8086 Assembly language for the DOS environment. The game is entirely text-based and runs in the 80x25 video text mode using BIOS interrupts and direct video memory access. It simulates the traditional snake game where the player controls the snake using arrow keys, collects food, and avoids self-collision.

🎮 Features
Real-time keyboard input for controlling the snake using arrow keys

Food spawning and score tracking

Snake body growth on food consumption

Game Over detection on collision

Centered title screen and score display

Buffer-based rendering for smoother visuals

🛠 Requirements
DOS environment or emulator (e.g., DOSBox)

NASM Assembler

8086-compatible code (COM file format)

▶️ How to Run (Using NASM)
Assemble the code using NASM:

bash
Copy
Edit
nasm snakegame.asm -f bin -o snakegame.com
Run the game in DOSBox:

bash
Copy
Edit
snakegame.com
💡 Make sure your code is written for .COM format (ORG 100h) for this to work correctly.

🎮 Controls
Arrow Keys: Move the snake in the respective direction

ESC: Quit the game

📁 File Structure
File	Description
snakegame.asm	Complete source code for the snake game
README.md	This documentation file

🧠 Concepts Used
BIOS & DOS interrupts (INT 10h, INT 16h, INT 1Ah, INT 21h)

Direct video memory access (0xB800)

String manipulation

Buffer-based rendering

Game loop, collision detection, and timing

📷 Screenshots
Title Screen Example:

vbnet
Copy
Edit
         █████████████████████████████████████
         █       WELCOME TO SNAKE GAME!     █
         █    PRESS ANY KEY TO START...     █
         █████████████████████████████████████
Gameplay Example:

markdown
Copy
Edit
Score: 0005
................................................
.............********...........................
................................................
🧩 Future Improvements
Add sound support using INT 10h or PC speaker

Add difficulty levels

High score saving

Colorful snake body rendering using attribute bytes

📜 License
This project is for educational purposes. Feel free to use and modify the code with attribution.
