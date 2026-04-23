# TheoryPocket

**TheoryPocket** is a comprehensive, interactive music theory and utility toolset built with Flutter. Whether you're learning the fundamentals of harmony, practicing complex rhythms, or composing your next track, TheoryPocket provides a suite of dynamic tools tailored for musicians of all levels.

---

## Features

- 🎡 **Circle of Fifths**  
  An interactive, sweeping visualization to navigate tonality, keys, and relative minors.

- 🎸 **Chord Dictionary**  
  A vast library to look up and learn the voicings of diverse chords across different instruments and fret/keyboard positions. Includes audio playback previews.

- 🎼 **Progression Builder**  
  Compose and save chord sequences intuitively. Supports transposition, custom song titles, and local offline storage so you never lose an idea.

- ⏱️ **Metronome & Tap Tempo**  
  A high-precision visual metronome featuring a swinging pendulum, beat visualizers, BPM slider, and a robust tap-tempo calculator.

- 🥁 **Polyrhythm Generator**  
  A specialized tool to layer different time signatures simultaneously (e.g., 3 against 4). Built with distinct concentric visualizations that pulse upon hitting overlapping beats.

- 📏 **Scale Formula Constructor**  
  An interactive tool teaching the underlying step math of scales. Users arrange Whole Step (W) and Half Step (H) blocks to build standard sequences (e.g., Major: W-W-H-W-W-W-H), which visually animates onto a dynamic fretboard and piano keyboard.

- 🐝 **Chord Spelling Bee**  
  A gamified, algorithmic tutor challenging you to spell chords from scratch on a live 12-note chromatic keyboard. Receive active pedagogical feedback when intervals mismatch.

- 🧠 **Progression Analyzer ("Why Does This Work?")**  
  Input any chord sequence and the analyzer evaluates its functional harmony in real-time, mapping Roman Numerals and explaining complex resolutions like Secondary Dominants and Minor Plagal Cadences.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable recommended)
- Dart SDK
- A connected device or emulator (Android / iOS / macOS / Windows / Linux)

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/theorypocket.git
   cd theorypocket
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the App:**
   ```bash
   flutter run
   ```
   _(Note for desktop platforms: TheoryPocket utilizes `sqflite_common_ffi` which automatically initializes under the hood for desktop compatibility.)_

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.
