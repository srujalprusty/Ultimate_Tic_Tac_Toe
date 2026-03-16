# 🎮 Ultimate Tic-Tac-Toe

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge"/>
</p>

<p align="center">
  A strategic, cartoon-styled mobile game built with Flutter.<br/>
  Play with a friend on the same device — or challenge a smart AI opponent.
</p>

---

## 📱 Screenshots

> _Add your own screenshots here after building the app._

| Home Screen | Game Screen | Game Over |
|:-----------:|:-----------:|:---------:|
| ![home](#)  | ![game](#)  | ![over](#)|

---

## ✨ Features

- 🎮 **2-Player Local** — Pass & play with a friend on the same device
- 🤖 **vs AI** — Challenge a Minimax AI with alpha-beta pruning
- 🧠 **3 Difficulty Levels** — Easy (random), Medium (depth 4), Hard (depth 6)
- 🎨 **Cartoon UI** — Bubbly dark theme with animated player chips, floating stars, and bouncing dots
- ⚡ **Smooth Animations** — Pop-in cells, pulsing arrows, glowing active boards
- 📳 **Haptic Feedback** — Light tap on every move
- 🔒 **Portrait Locked** — Clean single-orientation layout
- 🚀 **Non-blocking AI** — Runs in a Flutter `compute()` isolate, UI never freezes

---

## 🕹️ How to Play

Ultimate Tic-Tac-Toe is played on a **3×3 grid of smaller 3×3 boards**.

| Rule | Description |
|------|-------------|
| 📍 **Send your opponent** | Where you play inside a small board determines which small board your opponent must play in next |
| 🏆 **Win a small board** | Get three in a row inside any small board |
| 🌟 **Win the game** | Win three small boards in a row on the big outer board |
| 🆓 **Free move** | If you're sent to a board already won or full, you may play anywhere |

---

## 🗂️ Project Structure

```
ultimate_tictactoe/
├── lib/
│   ├── main.dart                    # App entry point, Provider setup, orientation lock
│   ├── theme/
│   │   └── app_theme.dart           # Dark colour palette, text theme, button styles
│   ├── models/
│   │   ├── game_state.dart          # ChangeNotifier — full game logic & state
│   │   └── ai_engine.dart           # Minimax AI engine (runs via compute isolate)
│   ├── screens/
│   │   ├── home_screen.dart         # Menu — mode picker, difficulty selector, how-to-play
│   │   └── game_screen.dart         # Main game UI — cartoon redesign
│   └── widgets/
│       ├── ultimate_board.dart      # 3×3 grid of SmallBoardWidgets
│       ├── small_board.dart         # One mini-board + won overlay
│       └── cell_widget.dart         # Individual tappable cell with animation
├── pubspec.yaml                     # Dependencies & Flutter config
└── README.md                        # You are here
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK 3.x](https://flutter.dev/docs/get-started/install) installed
- Android Studio / Xcode for device/emulator
- A connected device or running emulator

### Run locally

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/ultimate-tictactoe.git
cd ultimate-tictactoe

# 2. Install dependencies
flutter pub get

# 3. Run on connected device or emulator
flutter run
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | `^6.1.2` | State management |
| `google_fonts` | `^6.2.1` | Fredoka One + Nunito cartoon fonts |
| `cupertino_icons` | `^1.0.6` | iOS-style icons |

---

## 🤖 AI Details

The AI uses **Minimax with Alpha-Beta Pruning** and always plays as `O`.

| Difficulty | Search Depth | Behaviour |
|------------|-------------|-----------|
| 😊 Easy    | 1           | Random legal move |
| 🤔 Medium  | 4           | Solid positional play |
| 😈 Hard    | 6           | Strong lookahead — plans several moves ahead |

The AI runs inside Flutter's `compute()` isolate so it never blocks the main UI thread. A bouncing-dots animation plays while it thinks.

---

## 🏗️ Build for Release

### Android (Google Play)

```bash
flutter build appbundle --release
```

Upload the `.aab` file from:
```
build/app/outputs/bundle/release/app-release.aab
```

### iOS (App Store)

```bash
flutter build ipa --release
```

Open `ios/Runner.xcworkspace` in Xcode → Archive → Upload via Xcode Organizer.

---

## 🎨 Customisation

| What to change | Where |
|----------------|-------|
| Colours & theme | `lib/theme/app_theme.dart` |
| Cartoon colours | `_C` class in `lib/screens/game_screen.dart` |
| AI search depth | `_depths` list in `lib/models/ai_engine.dart` |
| Add sound effects | Integrate `audioplayers` package, call in `cell_widget.dart` |
| Score tracking | Add a scores map to `GameState`, persist with `shared_preferences` |
| Add new fonts | Replace `GoogleFonts.fredokaOne` / `GoogleFonts.nunito` in `game_screen.dart` |

---

## 📄 License

```
MIT License

Copyright (c) 2025 YOUR NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## 🙌 Acknowledgements

- Game concept: [Ultimate Tic-Tac-Toe](https://en.wikipedia.org/wiki/Ultimate_tic-tac-toe)
- Built with ❤️ using [Flutter](https://flutter.dev)
