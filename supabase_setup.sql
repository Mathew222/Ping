-- Supabase Database Setup for Ping Reminders App
-- Run this SQL in your Supabase SQL Editor

-- ============================================
-- 1. Create reminders table
-- ============================================

CREATE TABLE IF NOT EXISTS reminders (
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
  deleted_at TIMESTAMPTZ
);

-- ============================================
-- 2. Create indexes for performance
-- ============================================

CREATE INDEX IF NOT EXISTS idx_reminders_user_id ON reminders(user_id);
CREATE INDEX IF NOT EXISTS idx_reminders_trigger_at ON reminders(trigger_at);
CREATE INDEX IF NOT EXISTS idx_reminders_status ON reminders(status);
CREATE INDEX IF NOT EXISTS idx_reminders_deleted_at ON reminders(deleted_at) WHERE deleted_at IS NULL;

-- ============================================
-- 3. Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. Create RLS Policies
-- ============================================

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

-- ============================================
-- 5. Create updated_at trigger
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_reminders_updated_at
  BEFORE UPDATE ON reminders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Setup Complete!
-- ============================================

-- Verify the table was created
SELECT 
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'reminders'
ORDER BY ordinal_position;
