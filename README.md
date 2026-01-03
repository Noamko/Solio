# Solio 🎼

A beautiful SwiftUI app for mastering music note reading. Practice identifying notes on the musical staff with multiple game modes, difficulty levels, and customizable settings.

![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green)

## Features

### 🎮 Game Modes

- **Practice** — Learn at your own pace with configurable round lengths
- **Timed Challenge** — How many notes can you identify in 60 seconds?
- **Streak** — Don't miss a single note! See how long you can go

### 🎯 Difficulty Levels

| Level | Description |
|-------|-------------|
| Beginner | Notes on staff lines only |
| Easy | Notes on lines and spaces |
| Medium | Includes 1 ledger line |
| Hard | Includes 2 ledger lines |
| Expert | Full range with 3 ledger lines |

### 🎵 Customization

- **Clef Selection** — Treble (Sol), Bass (Fa), or Random
- **Input Styles** — Solfège (Do-Re-Mi), Letter notation (C-D-E), or Piano keyboard
- **Note Filtering** — Practice specific notes you want to improve
- **Metronome** — Built-in metronome with adjustable BPM (60-150)
- **Sound** — Audio feedback with mute option

### 📊 Statistics

Track your progress with detailed statistics for each note, including accuracy percentages and total attempts.

## Requirements

- iOS 17.0+ / macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Solio.git
   ```

2. Open `Solio.xcodeproj` in Xcode

3. Build and run on your device or simulator

## Project Structure

```
Solio/
├── Solio.swift           # App entry point
├── ContentView.swift     # Root view
├── HomeView.swift        # Main menu with settings
├── GameView.swift        # Game screen
├── GameViewModel.swift   # Game logic and state management
├── Models.swift          # Data models and enums
├── MusicStaffView.swift  # Musical staff rendering
├── NoteButtonsView.swift # Note selection buttons
├── PianoKeysView.swift   # Piano keyboard input
├── AudioManager.swift    # Sound playback
├── StatsManager.swift    # Statistics persistence
├── StatsView.swift       # Statistics display
└── Sounds/               # Audio files (Do-Si)
```

## How to Play

1. **Choose your settings** — Select game mode, difficulty, clef, and input style
2. **Filter notes** (optional) — Focus on specific notes you want to practice
3. **Start playing** — Identify the note shown on the staff
4. **Track progress** — View your stats to see improvement over time

## License

MIT License — feel free to use this project for learning or as a base for your own music education apps.

---

Made with ♪ and SwiftUI


