# Dosely (Hackathon Project)

> **An accessibility-first mobile app that turns confusing medication labels into clear, personalized, and spoken dosing plans to help people take their medicine safely.**

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Gemini](https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white)

---

## What is Dosely?

Dosely is a **hackathon project** designed to help people understand their medications safely. Simply scan a medication label or search by name, and Dosely will:

- **Extract & Verify** medication info using OCR + Gumloop web search
- **Analyze for Conflicts** with your existing medications and health profile
- **Generate Personalized Guidance** based on your allergies & conditions
- **Read Everything Aloud** with AI-powered voice synthesis
- **Translate to Any Language** on-the-fly with AI

---

## Key Features

### Smart Scanning Pipeline
1. **OCR** - Extracts text from medication labels
2. **Gumloop Verification** - Double-checks via Google search
3. **AI Analysis** - Deep research on drug interactions, side effects, and personalized risks

### Accessibility First
- **Text-to-Speech** with ElevenLabs (choice of 3 voices)
- **Adjustable Text Size** (Normal, Large, Extra Large)
- **Colorblind Modes** (Deuteranopia, Protanopia, Tritanopia)
- **Simple Mode** - "Explain Like I'm 12" for easy understanding

### Universal Language Support
- Built-in English & French
- **Any Language** - Type "German", "Japanese", etc. and the entire app translates via AI

### Medication Management
- Drug interaction detection (Safe / Caution / Conflict)
- Daily schedule with "Next Dose" countdown
- Personalized risk warnings based on your profile

---

## Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile UI |
| **Google Gemini 2.5 Flash** | AI analysis, OCR, translation |
| **ElevenLabs API** | Text-to-speech synthesis |
| **Gumloop** | Web search verification pipeline |
| **Provider** | State management |
| **SharedPreferences** | Local data persistence |

---

## Quick Start

### Prerequisites
- Flutter SDK 3.7+
- Android Studio or VS Code with Flutter extensions

### Setup

1. **Clone and install:**
   ```bash
   git clone https://github.com/Processuales/Dosely.git
   cd Dosely
   flutter pub get
   ```

2. **Add your API keys:**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys:
   # - GEMINI_API_KEY
   # - ELEVENLABS_API_KEY  
   # - GUMLOOP_API_KEY
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Build APK:**
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Screenshots

| Home | Scan Result | Schedule |
|------|-------------|----------|
| Scan button & recent meds | AI-analyzed medication info | Daily dosing plan |

| Profile | Settings | Read Aloud |
|---------|----------|------------|
| Allergies & conditions | Text size & voice selection | TTS voice options |

---

## Project Structure

```
lib/
├── core/
│   ├── config/ai_prompts.dart    # AI prompt templates
│   ├── models/                    # Data models
│   ├── providers/                 # State management
│   ├── services/
│   │   ├── ai_service.dart       # Gemini API integration
│   │   ├── voice_service.dart    # ElevenLabs TTS
│   │   └── gumloop_service.dart  # Web verification
│   └── theme/app_theme.dart      # Design system
├── l10n/                         # Localizations
└── presentation/
    ├── screens/                  # All app screens
    └── widgets/                  # Reusable components
```

---

## Environment Variables

Create a `.env` file in the project root:

```env
GEMINI_API_KEY=your_gemini_api_key
ELEVENLABS_API_KEY=your_elevenlabs_api_key
GUMLOOP_API_KEY=your_gumloop_api_key
```

---

## Design System

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#137FEC` | Buttons, accents |
| Safe | `#15803D` | No conflicts |
| Caution | `#B45309` | Minor warnings |
| Conflict | `#BE123C` | Drug interactions |

**Typography:** Lexend (Google Fonts)

---

## Team

Built for the **24-hour hackathon**

---

## License

This project was created for educational and demonstration purposes during a hackathon.

---

*"Because everyone deserves to understand their medications safely."*
