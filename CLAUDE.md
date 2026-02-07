# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fyx is an unofficial mobile client (Android & iOS) for the Czech discussion server Nyx.cz, built using Flutter. The repository is managed in Czech (issues, discussions), but source code and comments are written in English.

- **Flutter Version**: ^3.3.0
- **Dart SDK**: >=3.0.0 <4.0.0
- **Current Version**: 12.0.0+181
- **Target Platforms**: iOS 15.0+, Android API 21+, Android SDK 35
- **NDK Version**: 27.0.12077973

## Development Setup

### Prerequisites

- Flutter SDK (version managed via `fvm`)
- iOS: Xcode, CocoaPods
- Android: Android Studio, Gradle
- Firebase configuration (see CI/CD section in README.md)
- Environment file: Copy `.env.example` to `.env` and configure

### Getting Dependencies

```bash
# Using Flutter Version Manager
fvm flutter pub get

# iOS specific
cd ios && pod install && cd ..
```

### Running the App

```bash
# Development build (default environment)
fvm flutter run

# Production build
fvm flutter run -t lib/main_production.dart

# iOS
fvm flutter run -t lib/main_production.dart

# Android
fvm flutter run -t lib/main_production.dart
```

### Testing

```bash
# Run all tests
fvm flutter test

# Run specific test file
fvm flutter test test/api_test.dart
fvm flutter test test/helpers/parseDiscussionUri_test.dart
```

### Building

Use the provided `build.sh` script which handles version bumping and builds:

```bash
# Build both platforms (auto-increments build number)
./build.sh

# Keep current build number
./build.sh -k

# Build iOS only
./build.sh -i

# Build Android only
./build.sh -a
```

The script:
- Auto-increments the build number in `pubspec.yaml` (unless `-k` flag is used)
- For iOS: Cleans, builds, opens Xcode workspace
- For Android: Builds app bundle, outputs to `build/app/outputs/bundle/release/`

### Code Generation

```bash
# Generate Hive type adapters and other generated code
fvm flutter pub run build_runner build

# Watch mode for continuous generation
fvm flutter pub run build_runner watch
```

## Architecture

### Application Entry Points

- **Production**: `lib/main_production.dart` - Main entry point for production builds
- **Development**: Standard Flutter entry (dev environment)
- **Root App**: `lib/FyxApp.dart` - Core application configuration, routing, Firebase initialization

### Core Structure

**State Management**:
- Uses `flutter_riverpod` (v2.0.0-dev.4) for reactive state management
- Provider-based architecture with `NotificationsModel`, `ThemeModel`
- Riverpod providers located in `lib/state/` directory

**API Layer**:
- `lib/controllers/ApiController.dart` - Singleton managing all API calls
- `lib/controllers/ApiProvider.dart` - HTTP client wrapper using Dio
- `lib/controllers/IApiProvider.dart` - API provider interface
- Authentication handled through credential storage (SharedPreferences)

**Data Models**:
- Request/response models in `lib/model/reponses/`
- Domain models in `lib/model/` (Post, Discussion, Mail, etc.)
- Enums in `lib/model/enums/`
- Hive is used for local storage (see generated `.g.dart` files)

**Features (Clean Architecture)**:
- `lib/features/` - Feature modules following Clean Architecture
- Each feature has `domain/` (entities, repositories interfaces), `data/` (models, repository implementations, datasources), and `presentation/` layers
- Uses `freezed` for immutable entities/models with code generation
- Uses `sqflite` for SQLite database storage
- Example: `lib/features/userstats/` - User statistics tracking (scroll distance, likes, discussion visits, daily usage streaks)

**Pages (Screens)**:
- `lib/pages/HomePage.dart` - Main tabbed interface
- `lib/pages/DiscussionPage.dart` - Discussion/thread view
- `lib/pages/LoginPage.dart` - Authentication
- `lib/pages/NewMessagePage.dart` - Compose new post/message
- Other pages in `lib/pages/` and `lib/pages/tab_bar/`

**Components (Reusable UI)**:
- `lib/components/` - Reusable widgets
- `lib/components/post/` - Post-related components (avatar, rating, thumbs, etc.)
- `lib/components/bottom_sheets/` - Modal bottom sheets

**Theming/Skinning**:
- `lib/theme/` - Theme system
- `lib/theme/skin/` - Pluggable skin system
- `lib/theme/skin/skins/` - Available skins: Fyx (default), Forest, GreyMatter, Dark
- Theme enum supports light/dark/system modes
- Premium users can access all skins

### Navigation

- CupertinoPageRoute-based navigation
- Routes defined in `FyxApp.routes()` method
- Deep linking support for discussions, posts, mail
- Global navigator key: `FyxApp.navigatorKey`

### Firebase Integration

- Crashlytics for error reporting
- Performance monitoring
- Analytics via `AnalyticsProvider`
- FCM for push notifications via `NotificationService`
- Configuration in `lib/firebase_options.dart` and `lib/libs/firebase_options.dart`

### Services

- `lib/controllers/NotificationsService.dart` - FCM push notifications
- `lib/controllers/SettingsProvider.dart` - User preferences management
- `lib/controllers/drafts_service.dart` - Draft post persistence
- `lib/controllers/log_service.dart` - Logging abstraction with Firebase provider
- `lib/controllers/AnalyticsProvider.dart` - Analytics wrapper

### Dependency Injection

- `lib/shared/services/service_locator.dart` - GetIt DI container setup
- Global accessor: `userstatsRepo` for UserstatsRepository

### Repository Pattern

- `lib/model/MainRepository.dart` - Singleton holding app-wide state (credentials, settings, device info, etc.)

## Git Workflow

This repository uses **Gitflow**:
- `master` - Production releases
- `develop` - Development branch
- `feature/*` - Feature branches

**Important**:
- Always branch from `develop`
- Submit PRs to `develop` (not `master`)
- PRs are squash-merged by admins only
- CI/CD builds trigger on tags matching `vX.Y.Z+XXX` format

## Common Gotchas

- **Environment**: App has dev/staging/production environments set via `FyxApp.setEnv()`
- **Credentials**: Stored in SharedPreferences as JSON
- **Premium Features**: Checked via Supabase (`subscribers` table)
- **Let's Encrypt Certificate**: Custom cert loaded in main for Nyx.cz compatibility
- **Dependency Override**: `app_links: 6.3.0` is pinned (see pubspec.yaml comment)
- **iOS Deployment Target**: Set to 15.0 in Podfile
- **Android Compile SDK**: Version 35
