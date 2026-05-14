# Gem Hub

A Flutter application for managing gem market inventory, jobs, user profiles, and reports.

## Overview

`Gem_Hub` is a multi-platform Flutter app with modules for:

- Authentication
- Gem marketplace browsing and management
- Inventory tracking
- Job listings
- Profile and reports

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK included with Flutter
- Android Studio / Xcode or required platform tooling for your target devices

### Install dependencies

From the project root:

```bash
flutter pub get
```

### Run the app

- Android:

```bash
flutter run -d android
```

- iOS:

```bash
flutter run -d ios
```

- Web:

```bash
flutter run -d chrome
```

## Project Structure

- `lib/main.dart` — App entry point
- `lib/core/` — API, constants, providers, router, and shared data
- `lib/features/` — Feature modules for auth, gem market, home, inventory, jobs, navigation, profile, and reports
- `lib/shared/widgets/` — Reusable widgets

## Notes

- Keep platform-specific configuration in `android/`, `ios/`, `linux/`, `macos/`, `windows/`, and `web/`
- Update dependencies in `pubspec.yaml`

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Flutter packages](https://pub.dev/)
