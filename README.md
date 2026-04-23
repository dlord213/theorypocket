# TheoryPocket 🎸🎹🎼

**TheoryPocket** is a comprehensive, interactive music theory and utility toolset built with Flutter. Whether you're learning the fundamentals of harmony, practicing complex rhythms, or composing your next track, TheoryPocket provides a suite of dynamic tools tailored for musicians of all levels.

---

## ✨ Features

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

---

## 🎨 Design System

TheoryPocket abandons static color styling in favor of a strictly dynamic **Material 3 / OneUI** design language:

- Full support for adaptive **Light and Dark mode** driven by system preferences.
- Uses `Theme.of(context).colorScheme` throughout, offering dynamic and consistent tones across all components.
- Heavily utilizes smooth, tactile micro-animations (e.g., custom scale taps, sweeping radials, pendulum paths) and rich visual feedback.

---

## 🚀 Getting Started

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

## 📦 Tech Stack

- **Framework:** Flutter / Dart
- **Design:** Material 3, Google Fonts
- **State Management:** Riverpod (`hooks_riverpod`)
- **Routing:** Go Router
- **Database:** SQLite (`sqflite` & `sqflite_common_ffi`)

---

## 🤝 Contributing

Contributions are welcome!

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
