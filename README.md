# streaks.

A free, open-source habit tracker with a dot-grid visualization. No paywalls, no accounts.

## Features

- **182-day dot grid** per habit — 26 weeks at a glance
- **Full emoji picker** — every emoji Android provides, with search and recents
- **Color wheel** — pick any color, not just a preset palette
- **Streak tracking** — current and longest streak per habit
- **Stats tab** — 7-day / 30-day completion rates, total checks
- **Collapsible stats** — tap the arrow on the home screen to hide/show the summary bar
- **Drag to reorder** — long-press and drag habits into any order
- **Swipe to delete** — swipe left on any habit card
- **Long-press to edit** — rename, change icon or color anytime
- **Offline & private** — data stored locally on device, nothing sent anywhere

## Getting the APK

### Option 1: GitHub Actions (recommended)
Every push to `main` automatically builds APKs. Go to:
**Actions → Build APK → latest run → Artifacts → release-apks**

Download and install `app-arm64-v8a-release.apk` for most modern Android phones.

### Option 2: Build locally
```bash
flutter pub get
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Option 3: Tagged release
Push a version tag to create a GitHub Release with APKs attached:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Install on Android

1. Download the APK to your phone
2. Go to **Settings → Install unknown apps** and allow your browser/file manager
3. Open the APK file and tap Install

## Local development

```bash
# Requirements: Flutter 3.24+ and Android SDK
flutter pub get
flutter run        # debug on connected device
flutter build apk  # release APK
```

## Project structure

```
lib/
├── main.dart                  # App entry, navigation
├── theme.dart                 # Colors, typography
├── models/
│   └── habit.dart             # Habit data + streak logic
├── providers/
│   └── habits_provider.dart   # State management + persistence
├── screens/
│   ├── home_screen.dart       # Habits list + collapsible stats
│   └── stats_screen.dart      # Detailed analytics tab
└── widgets/
    ├── habit_card.dart        # Card with dot grid + check button
    ├── dot_grid.dart          # The 182-day dot visualization
    └── add_habit_sheet.dart   # Add/edit sheet with emoji + color picker
```

## Tech

- Flutter 3.24 / Dart 3
- `shared_preferences` — local persistence
- `emoji_picker_flutter` — full Android emoji keyboard
- `flutter_colorpicker` — HSV color wheel
- `provider` — state management

## License

MIT
