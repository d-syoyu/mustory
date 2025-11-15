# Supabase Setup Guide

This guide explains how to set up Supabase authentication for the Mustory API.

## Overview

Mustory uses **Supabase Auth** for user authentication, providing:
- Email/password authentication
- JWT-based session management
- Future support for OAuth (Google, GitHub, etc.) and Passkeys
- Built-in security best practices

## Quick Start

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Fill in:
   - **Project Name**: `mustory` (or your preferred name)
   - **Database Password**: (generate a strong password)
   - **Region**: Choose closest to your users
4. Wait for project to initialize (~2 minutes)

### 2. Get API Credentials

From your Supabase project dashboard:

1. Go to **Settings** → **API**
2. Copy the following values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public** key (for client-side)
   - **service_role** key (for server-side, keep secret!)

### 3. Configure Environment Variables

#### Local Development

Create `.env` file in `apps/api/`:

```bash
# Supabase Configuration
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Database (Supabase provides this)
DATABASE_URL=postgresql://postgres:[password]@db.xxxxx.supabase.co:5432/postgres

# Other settings
ENVIRONMENT=local
REDIS_URL=redis://localhost:6379/0
```

#### Docker Deployment

Update `infra/docker-compose.yml` or use `.env` file:

```yaml
services:
  api:
    environment:
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
      - SUPABASE_SERVICE_KEY=${SUPABASE_SERVICE_KEY}
```

#### Production (Railway/Render)

Add environment variables in your hosting platform:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_KEY`

### 4. Configure Supabase Database Schema

**We use Supabase's PostgreSQL database for everything** - both Auth and application data.

#### Get Database Connection String

1. In Supabase Dashboard, go to **Settings** → **Database**
2. Find "Connection string" section
3. Select **"Direct connection"** tab
4. Copy the connection string (it looks like):
   ```
   postgresql://postgres.xxxxx:[YOUR-PASSWORD]@aws-0-[region].pooler.supabase.com:5432/postgres
   ```
5. Replace `[YOUR-PASSWORD]` with your database password

#### Run Migrations on Supabase

```bash
cd apps/api

# Update .env with Supabase database URL
echo 'DATABASE_URL=postgresql://postgres.xxxxx:[password]@...' >> .env

# Run migrations to create tables
alembic upgrade head
```

This creates your application tables (`tracks`, `stories`, `comments`) in the same Supabase database alongside the Auth tables.

#### Database Schema Overview

After migration, your Supabase database contains:

**Supabase-managed (auth schema):**
- `auth.users` - User accounts
- `auth.sessions` - Active sessions
- `auth.identities` - OAuth providers

**Your application (public schema):**
- `public.tracks` - Music tracks
- `public.stories` - Track stories
- `public.comments` - Comments
- `public.alembic_version` - Migration tracking

#### User ID Relationships

- Supabase creates UUIDs in `auth.users.id` when users sign up
- Your tables reference this UUID as `user_id` or `author_user_id`
- The relationship is automatic - no extra setup needed!

### 5. Test Authentication

Start the API server:
```bash
cd apps/api
uvicorn app.main:app --reload
```

Visit http://localhost:8000/docs and test:

1. **POST `/auth/signup`**
   ```json
   {
     "email": "test@example.com",
     "password": "securepassword123",
     "display_name": "Test User"
   }
   ```

2. **POST `/auth/login`**
   ```json
   {
     "email": "test@example.com",
     "password": "securepassword123"
   }
   ```

3. **GET `/auth/me`** (with Bearer token from login response)

## Mobile App Integration

### Flutter Setup

1. Install Supabase Flutter SDK:
   ```yaml
   dependencies:
     supabase_flutter: ^2.0.0
   ```

2. Initialize Supabase:
   ```dart
   import 'package:supabase_flutter/supabase_flutter.dart';

   await Supabase.initialize(
     url: 'https://xxxxx.supabase.co',
     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
   );

   final supabase = Supabase.instance.client;
   ```

3. Sign up:
   ```dart
   final response = await supabase.auth.signUp(
     email: 'user@example.com',
     password: 'password123',
     data: {'display_name': 'User Name'},
   );
   ```

4. Sign in:
   ```dart
   final response = await supabase.auth.signInWithPassword(
     email: 'user@example.com',
     password: 'password123',
   );
   ```

5. Use token with API:
   ```dart
   final session = supabase.auth.currentSession;
   final token = session?.accessToken;

   // Use token in HTTP headers
   final response = await http.get(
     Uri.parse('http://localhost:8000/tracks/123'),
     headers: {'Authorization': 'Bearer $token'},
   );
   ```

## Advanced Features

### Email Confirmation

1. Go to **Authentication** → **Settings** in Supabase Dashboard
2. Enable "Email Confirmations"
3. Customize email templates

### OAuth Providers (Google, GitHub, etc.)

1. Go to **Authentication** → **Providers**
2. Enable desired providers
3. Configure OAuth credentials
4. Use in Flutter:
   ```dart
   await supabase.auth.signInWithOAuth(OAuthProvider.google);
   ```

### Passkey Support

Coming soon in Supabase Auth.

## Security Best Practices

1. ✅ **Never expose `service_role` key** to clients
2. ✅ Use `anon` key for mobile/web clients
3. ✅ Enable Row Level Security (RLS) in Supabase
4. ✅ Set strong password policies in Supabase Dashboard
5. ✅ Enable email confirmation for production
6. ✅ Use HTTPS only in production

## Troubleshooting

### "Supabase credentials not configured" Error

Make sure environment variables are set:
```bash
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY
```

### Authentication Fails

1. Check Supabase Dashboard → **Authentication** → **Users**
2. Verify email is confirmed (if required)
3. Check API logs for detailed error messages

### Token Expired

Tokens expire after 1 hour by default. Implement token refresh:

```dart
supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  // Store new token
});
```

## Migration from Self-Hosted Auth

If you previously used self-hosted JWT auth:

1. Export existing users
2. Import to Supabase via Admin API
3. Update mobile apps to use Supabase SDK
4. Remove old auth code

## Resources

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Flutter SDK Docs](https://supabase.com/docs/reference/dart/introduction)
- [Supabase Dashboard](https://app.supabase.com)
