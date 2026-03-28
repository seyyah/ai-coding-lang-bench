# mini-timer (VERSION: v1)
A command-line Pomodoro and time-tracking application designed for deep focus.

## 🚀 V1 Features
This version upgrades the prototype into a functional tool:
* **Active Controls:** Implemented `pause`, `resume`, and `stop` commands.
* **Focus Guard:** A strict limit of **3 pauses** per task to prevent distractions.
* **Human-Readable Time:** All durations are displayed in `MM:SS` (or `HH:MM:SS`) format instead of raw seconds (Requirement 6).
* **Smart Tracking:** Real-time timestamp calculation using Python's `time` module.

## 🛠 Commands
1. `python solution_v1.py init` - Initialize the system.
2. `python solution_v1.py start "Task Name"` - Start focusing on a new task.
3. `python solution_v1.py pause` - Take a break (Max 3 pauses allowed).
4. `python solution_v1.py resume` - Resume your active task.
5. `python solution_v1.py stop` - Finish the task and display the total duration.

## 👨‍💻 Author
Ömer Faruk Aksoy (251478060)
*Developed as part of the V1 Project Milestone.*