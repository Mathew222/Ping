-- ============================================
-- Enable Supabase Realtime for Reminders Table
-- ============================================
-- Run this SQL in your Supabase SQL Editor to enable real-time syncing
-- between devices without requiring app restart

-- Enable Realtime replication for the reminders table
ALTER PUBLICATION supabase_realtime ADD TABLE reminders;

-- Verify Realtime is enabled (optional check)
-- This query shows all tables that have Realtime enabled
SELECT 
  schemaname,
  tablename
FROM 
  pg_publication_tables
WHERE 
  pubname = 'supabase_realtime'
  AND tablename = 'reminders';

-- ============================================
-- Expected Result:
-- ============================================
-- You should see one row with:
--   schemaname | tablename
--   -----------+-----------
--   public     | reminders
--
-- If you see this row, Realtime is successfully enabled!
-- ============================================
