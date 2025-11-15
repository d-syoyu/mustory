-- Row Level Security (RLS) Policies for Mustory
-- Execute these SQL statements in Supabase SQL Editor (https://app.supabase.com/project/_/sql)

-- ============================================================
-- DROP EXISTING POLICIES (if any)
-- ============================================================

DROP POLICY IF EXISTS "tracks_select_all" ON public.tracks;
DROP POLICY IF EXISTS "tracks_insert_own" ON public.tracks;
DROP POLICY IF EXISTS "tracks_update_own" ON public.tracks;
DROP POLICY IF EXISTS "tracks_delete_own" ON public.tracks;

DROP POLICY IF EXISTS "stories_select_all" ON public.stories;
DROP POLICY IF EXISTS "stories_insert_authenticated" ON public.stories;
DROP POLICY IF EXISTS "stories_update_own" ON public.stories;
DROP POLICY IF EXISTS "stories_delete_own" ON public.stories;

DROP POLICY IF EXISTS "comments_select_all" ON public.comments;
DROP POLICY IF EXISTS "comments_insert_authenticated" ON public.comments;
DROP POLICY IF EXISTS "comments_delete_own" ON public.comments;

DROP POLICY IF EXISTS "alembic_version_select_all" ON public.alembic_version;

-- ============================================================
-- TRACKS TABLE
-- ============================================================

-- Enable RLS on tracks table
ALTER TABLE public.tracks ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read tracks
CREATE POLICY "tracks_select_all" ON public.tracks
  FOR SELECT
  USING (true);

-- Policy: Authenticated users can insert their own tracks
CREATE POLICY "tracks_insert_own" ON public.tracks
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own tracks
CREATE POLICY "tracks_update_own" ON public.tracks
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own tracks
CREATE POLICY "tracks_delete_own" ON public.tracks
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================================
-- STORIES TABLE
-- ============================================================

-- Enable RLS on stories table
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read stories
CREATE POLICY "stories_select_all" ON public.stories
  FOR SELECT
  USING (true);

-- Policy: Authenticated users can create stories
CREATE POLICY "stories_insert_authenticated" ON public.stories
  FOR INSERT
  WITH CHECK (auth.uid() = author_user_id);

-- Policy: Users can update their own stories
CREATE POLICY "stories_update_own" ON public.stories
  FOR UPDATE
  USING (auth.uid() = author_user_id)
  WITH CHECK (auth.uid() = author_user_id);

-- Policy: Users can delete their own stories
CREATE POLICY "stories_delete_own" ON public.stories
  FOR DELETE
  USING (auth.uid() = author_user_id);

-- ============================================================
-- COMMENTS TABLE
-- ============================================================

-- Enable RLS on comments table
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read comments
CREATE POLICY "comments_select_all" ON public.comments
  FOR SELECT
  USING (true);

-- Policy: Authenticated users can create comments
CREATE POLICY "comments_insert_authenticated" ON public.comments
  FOR INSERT
  WITH CHECK (auth.uid() = author_user_id);

-- Policy: Users can delete their own comments
CREATE POLICY "comments_delete_own" ON public.comments
  FOR DELETE
  USING (auth.uid() = author_user_id);

-- ============================================================
-- ALEMBIC_VERSION TABLE (Migration tracking)
-- ============================================================

-- Enable RLS on alembic_version table
ALTER TABLE public.alembic_version ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read migration version (read-only)
CREATE POLICY "alembic_version_select_all" ON public.alembic_version
  FOR SELECT
  USING (true);

-- Note: No INSERT/UPDATE/DELETE policies - only service_role can modify
-- This ensures only backend migrations can update the version table

-- ============================================================
-- VERIFY POLICIES
-- ============================================================

-- Check all policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
