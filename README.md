# Catch the Falling Objects Game (Game Developer Internship — Week 1)

A cross-platform 2D mobile game built with **Flutter** and the **Flame Engine**. Objects spawn randomly at the top of the screen and fall downwards while the player controls a paddle at the bottom using touch/drag gestures to catch them and score points[cite: 26].

---

## 📌 Features & Mechanics

- **Touch & Drag Player Movement:** Smooth horizontal paddle control locked within device screen bounds[cite: 26].
- **Dynamic Object Spawner:** Randomly selects spawn X coordinates, fall speeds, and vibrant colors[cite: 26].
- **Collision Detection:** Axis-Aligned Bounding Box (AABB) overlap checking between falling targets and player basket[cite: 26].
- **Score & HUD Counter:** Real-time on-screen score display and miss counter tracking[cite: 26].
- **Difficulty Scaling:** Acceleration in object spawn rates as score milestones are reached.
- **Game Over & Restart System:** Tap-to-restart overlay triggered upon missing 5 objects.

---

## 🚀 How to Run

1. **Install Flutter SDK & Dependencies:**
   ```bash
   flutter pub get
   ```
