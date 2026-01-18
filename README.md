# 💊 Dosely - Hackathon Flutter App

> Turn any medication label into a safe, conflict-checked schedule with accessibility-first guidance, in seconds.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.7+ installed ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Android Studio or VS Code with Flutter extensions
- A physical Android device or emulator

### Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate localization files:**
   ```bash
   flutter gen-l10n
   ```

3. **Run the app (debug mode):**
   ```bash
   flutter run
   ```

4. **Build APK for testing:**
   ```bash
   flutter build apk --debug
   ```
   The APK will be at: `build/app/outputs/flutter-apk/app-debug.apk`

5. **Build release APK:**
   ```bash
   flutter build apk --release
   ```
   The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 App Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── theme/
│   │   └── app_theme.dart            # Design system (colors, typography)
│   └── providers/
│       └── settings_provider.dart    # State management for settings
├── l10n/
│   └── app_en.arb                    # English strings (add app_fr.arb for French!)
└── presentation/
    ├── screens/
    │   ├── main_shell.dart           # Bottom navigation shell
    │   ├── onboarding/               # First-time user flow
    │   ├── home/                     # Home screen with scan button
    │   ├── medications/              # Medication list
    │   ├── profile/                  # User profile
    │   ├── settings/                 # App settings
    │   ├── schedule/                 # Medication schedule (demo results)
    │   └── side_effects/             # Side effects info
    └── widgets/
        ├── dosely_header.dart        # App header with logo
        ├── primary_action_card.dart  # Big action buttons
        ├── secondary_action_button.dart
        └── medication_card.dart      # Medication list items
```

## 🌍 Adding New Languages

1. Create a new ARB file: `lib/l10n/app_fr.arb` (for French)
2. Copy content from `app_en.arb` and translate
3. Uncomment the locale in `lib/main.dart`:
   ```dart
   supportedLocales: const [
     Locale('en'),
     Locale('fr'), // Uncomment this
   ],
   ```
4. Run `flutter gen-l10n`

## ✨ Features Implemented

### Navigation
- ✅ Bottom navigation with 4 tabs (Home, My Meds, Profile, Settings)
- ✅ Screen routing between all pages
- ✅ Back navigation

### Screens
- ✅ **Onboarding** - Text size selection, disclaimer, name input
- ✅ **Home** - Scan button, recent scans, demo button
- ✅ **Medications** - List of saved meds with status badges
- ✅ **Profile** - User info, allergies, conditions
- ✅ **Settings** - Text size, voice speed, simple mode
- ✅ **Schedule** - Demo medication with conflict alert, daily timeline
- ✅ **Side Effects** - Tabbed view with common effects

### Accessibility
- ✅ Dynamic text scaling (Normal/Large/Extra Large)
- ✅ High contrast colors (WCAG AA compliant)
- ✅ Large touch targets (44x44px minimum)
- ✅ All text from localization (ready for TTS)

### AI & Scanning
- ✅ **Camera Integration** - Capture medication labels directly.
- ✅ **AI Analysis** - Gemini-powered verification of medication details.
- ✅ **Conflict Detection** - Checks new scans against your existing profile and medications.
- ✅ **Text-to-Speech** - "Read Aloud" functionality for accessibility.

## 🔧 Planned Features (Hackathon Scope)

- ⏳ Gumloop Integration (Automation flow)
- ❌ Persistent storage (currently in-memory)
- ❌ Offline Mode

## 🎨 Design System

## 🎨 Design System

Colors defined in `lib/core/theme/app_theme.dart`:
- **Primary:** `#137FEC` (Dosely Blue)
- **Safe:** `#15803D` (Green)
- **Caution:** `#B45309` (Amber)
- **Conflict:** `#BE123C` (Red)

Font: **Lexend** (from Google Fonts, auto-downloaded)

## 📦 Dependencies

```yaml
dependencies:
  flutter_localizations: sdk     # Multi-language support
  google_fonts: ^6.2.1          # Lexend typography
  provider: ^6.1.2              # State management
  shared_preferences: ^2.3.3    # Local storage (future)
```

## 👥 Team Dosely

Built for the 24-hour hackathon!

---

*"Because everyone deserves to understand their medications safely."*
