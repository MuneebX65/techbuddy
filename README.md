# techbuddy

A new Flutter project.

## Groq Setup

1. Set your key in `assets/env/app.env`:

   ```env
   GROQ_API_KEY=YOUR_GROQ_API_KEY
   GROQ_MODEL=llama-3.1-8b-instant
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

Optional for web:

```bash
flutter run -d chrome --dart-define=GROQ_API_KEY=YOUR_GROQ_API_KEY
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
