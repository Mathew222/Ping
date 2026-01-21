# Supabase Setup Guide

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign in with GitHub (recommended)
4. Click "New Project"
5. Fill in:
   - **Name**: ping-reminders (or your choice)
   - **Database Password**: (generate a strong password)
   - **Region**: Choose closest to your users
6. Click "Create new project"
7. Wait 2-3 minutes for setup

## Step 2: Get API Credentials

1. In your Supabase project dashboard
2. Go to **Settings** → **API**
3. Copy these values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## Step 3: Configure the App

Open `lib/core/config/supabase_config.dart` and replace:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

With your actual values:

```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

## Step 4: Create Database Table

1. In Supabase dashboard, go to **SQL Editor**
2. Click "New query"
3. Paste this SQL:

```sql
-- Create reminders table
CREATE TABLE reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  trigger_at TIMESTAMPTZ NOT NULL,
  original_trigger_at TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  priority TEXT NOT NULL DEFAULT 'medium',
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_rule JSONB,
  snoozed_until TIMESTAMPTZ,
  version INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  
  -- Indexes for performance
  INDEX idx_user_id (user_id),
  INDEX idx_trigger_at (trigger_at),
  INDEX idx_status (status)
);

-- Enable Row Level Security
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own reminders
CREATE POLICY "Users can view own reminders"
  ON reminders FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own reminders
CREATE POLICY "Users can insert own reminders"
  ON reminders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own reminders
CREATE POLICY "Users can update own reminders"
  ON reminders FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own reminders
CREATE POLICY "Users can delete own reminders"
  ON reminders FOR DELETE
  USING (auth.uid() = user_id);
```

4. Click "Run" to execute

## Step 5: Enable Google Sign-In (Optional)

1. Go to **Authentication** → **Providers**
2. Find "Google" and click to configure
3. Enable it
4. Add your OAuth credentials from Google Cloud Console
5. Save

## Step 6: Test the Setup

1. Hot restart your app
2. You should see "Supabase initialized successfully" in logs
3. No errors should appear

## Troubleshooting

### "Supabase initialization error"
- Check that URL and key are correct
- Make sure no extra spaces in config
- Verify internet connection

### "Row Level Security" errors
- Make sure RLS policies are created
- Check that user is authenticated
- Verify user_id matches auth.uid()

### Google Sign-In not working
- Check OAuth credentials
- Verify redirect URLs
- Test email/password first

## Next Steps

Once setup is complete:
- ✅ Supabase is initialized
- ✅ Database table created
- ✅ RLS policies active
- ✅ Ready for authentication!

Now you can proceed with implementing the login screen!
