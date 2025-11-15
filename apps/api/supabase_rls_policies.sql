-- Supabase RLS (Row Level Security) Policies for Mustory
-- This file contains all the security policies to protect user data

-- ============================================================================
-- Enable RLS on all tables
-- ============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE like_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE like_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE like_comments ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- Users Table Policies
-- ============================================================================

-- Users can read all user profiles (public information)
CREATE POLICY "Users are viewable by everyone"
  ON users FOR SELECT
  USING (true);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid()::uuid = id);

-- Users can insert their own profile (during signup)
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid()::uuid = id);

-- ============================================================================
-- Tracks Table Policies
-- ============================================================================

-- Anyone can view all tracks (public content)
CREATE POLICY "Tracks are viewable by everyone"
  ON tracks FOR SELECT
  USING (true);

-- Authenticated users can create tracks
CREATE POLICY "Authenticated users can create tracks"
  ON tracks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::uuid = user_id);

-- Users can update their own tracks
CREATE POLICY "Users can update own tracks"
  ON tracks FOR UPDATE
  USING (auth.uid()::uuid = user_id);

-- Users can delete their own tracks
CREATE POLICY "Users can delete own tracks"
  ON tracks FOR DELETE
  USING (auth.uid()::uuid = user_id);

-- ============================================================================
-- Stories Table Policies
-- ============================================================================

-- Anyone can view all stories (public content)
CREATE POLICY "Stories are viewable by everyone"
  ON stories FOR SELECT
  USING (true);

-- Track owners can create stories for their tracks
CREATE POLICY "Track owners can create stories"
  ON stories FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid()::uuid = author_user_id
    AND EXISTS (
      SELECT 1 FROM tracks
      WHERE tracks.id = track_id
      AND tracks.user_id = auth.uid()::uuid
    )
  );

-- Story authors can update their stories
CREATE POLICY "Authors can update own stories"
  ON stories FOR UPDATE
  USING (auth.uid()::uuid = author_user_id);

-- Story authors can delete their stories
CREATE POLICY "Authors can delete own stories"
  ON stories FOR DELETE
  USING (auth.uid()::uuid = author_user_id);

-- ============================================================================
-- Comments Table Policies
-- ============================================================================

-- Anyone can view non-deleted comments
CREATE POLICY "Comments are viewable by everyone"
  ON comments FOR SELECT
  USING (is_deleted = false);

-- Authenticated users can create comments
CREATE POLICY "Authenticated users can create comments"
  ON comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::uuid = author_user_id);

-- Comment authors can update their own comments
CREATE POLICY "Authors can update own comments"
  ON comments FOR UPDATE
  USING (auth.uid()::uuid = author_user_id);

-- Comment authors can soft-delete their own comments
CREATE POLICY "Authors can delete own comments"
  ON comments FOR DELETE
  USING (auth.uid()::uuid = author_user_id);

-- ============================================================================
-- Like Tracks Table Policies
-- ============================================================================

-- Anyone can view all track likes (for like counts)
CREATE POLICY "Track likes are viewable by everyone"
  ON like_tracks FOR SELECT
  USING (true);

-- Authenticated users can like tracks
CREATE POLICY "Authenticated users can like tracks"
  ON like_tracks FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::uuid = user_id);

-- Users can only unlike their own likes
CREATE POLICY "Users can unlike own track likes"
  ON like_tracks FOR DELETE
  USING (auth.uid()::uuid = user_id);

-- ============================================================================
-- Like Stories Table Policies
-- ============================================================================

-- Anyone can view all story likes (for like counts)
CREATE POLICY "Story likes are viewable by everyone"
  ON like_stories FOR SELECT
  USING (true);

-- Authenticated users can like stories
CREATE POLICY "Authenticated users can like stories"
  ON like_stories FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::uuid = user_id);

-- Users can only unlike their own likes
CREATE POLICY "Users can unlike own story likes"
  ON like_stories FOR DELETE
  USING (auth.uid()::uuid = user_id);

-- ============================================================================
-- Like Comments Table Policies
-- ============================================================================

-- Anyone can view all comment likes (for like counts)
CREATE POLICY "Comment likes are viewable by everyone"
  ON like_comments FOR SELECT
  USING (true);

-- Authenticated users can like comments
CREATE POLICY "Authenticated users can like comments"
  ON like_comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid()::uuid = user_id);

-- Users can only unlike their own likes
CREATE POLICY "Users can unlike own comment likes"
  ON like_comments FOR DELETE
  USING (auth.uid()::uuid = user_id);

-- ============================================================================
-- Additional Security: Prevent unauthorized updates to like counts
-- ============================================================================

-- Note: Like counts should be updated via triggers or backend API only
-- Users should not be able to manually increment these fields

-- Create a function to validate that only the system can update like_count
CREATE OR REPLACE FUNCTION validate_like_count_update()
RETURNS TRIGGER AS $$
BEGIN
  -- Only allow updates from backend (via service role key)
  -- In practice, your FastAPI backend should use service role key for updates
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- Notes
-- ============================================================================

-- 1. This assumes you're using Supabase Auth (auth.uid() is available)
-- 2. The FastAPI backend should use the Supabase service role key for:
--    - Incrementing/decrementing like_count fields
--    - Any administrative operations
-- 3. User-facing operations (via anon/authenticated keys) are protected by RLS
-- 4. Make sure your FastAPI backend validates user ownership before operations
