# Mustory Mobile - Setup Guide

## Prerequisites

- Flutter 3.38+
- Dart SDK 3.5.0+
- Supabase account

## Setup Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Supabase

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from the Supabase dashboard
3. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
4. Update `.env` with your Supabase credentials:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   MUSTORY_API_BASE_URL=http://localhost:8000
   ```

### 3. Run the App

With environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=your-anon-key \
            --dart-define=MUSTORY_API_BASE_URL=http://localhost:8000
```

Or create a launch configuration in VS Code (`.vscode/launch.json`):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "mustory_mobile",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define",
        "SUPABASE_URL=https://your-project.supabase.co",
        "--dart-define",
        "SUPABASE_ANON_KEY=your-anon-key",
        "--dart-define",
        "MUSTORY_API_BASE_URL=http://localhost:8000"
      ]
    }
  ]
}
```

### 4. Generate Code (if needed)

If you modify any Freezed models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Features Implemented

- ✅ Supabase Authentication (Sign up / Sign in / Sign out)
- ✅ Token management with flutter_secure_storage
- ✅ Auto token injection to API requests
- ✅ Auth-based routing with go_router
- ✅ Login and Signup screens

## Architecture

```
lib/
├── core/
│   ├── auth/
│   │   ├── auth_state.dart         # Auth state model (Freezed)
│   │   ├── auth_repository.dart    # Supabase auth operations
│   │   └── auth_controller.dart    # Auth state management (Riverpod)
│   └── network/
│       └── api_client.dart         # Dio client with auth interceptor
├── features/
│   └── auth/
│       └── presentation/
│           ├── login_page.dart     # Login screen
│           └── signup_page.dart    # Signup screen
└── app/
    ├── router.dart                 # App routing with auth guards
    └── theme.dart                  # App theme
```

## Next Steps

1. Connect to real API backend
2. Implement track listing
3. Add audio player
4. Implement story and comment features
