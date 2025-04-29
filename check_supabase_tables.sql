-- Script to check if the Supabase tables for Zwift Data Viewer exist
-- Run this in your Supabase SQL Editor to verify the setup

-- Check if tables exist
SELECT 
  table_name,
  EXISTS (
    SELECT 1 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'zw_activities'
  ) AS activities_exists,
  EXISTS (
    SELECT 1 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'zw_activity_details'
  ) AS activity_details_exists,
  EXISTS (
    SELECT 1 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'zw_activity_photos'
  ) AS activity_photos_exists,
  EXISTS (
    SELECT 1 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'zw_activity_streams'
  ) AS activity_streams_exists,
  EXISTS (
    SELECT 1 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'zw_segment_efforts'
  ) AS segment_efforts_exists
FROM (
  VALUES 
    ('zw_activities'),
    ('zw_activity_details'),
    ('zw_activity_photos'),
    ('zw_activity_streams'),
    ('zw_segment_efforts')
) AS t(table_name);

-- Check if RLS is enabled on tables
SELECT 
  table_name,
  rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
AND table_name IN (
  'zw_activities',
  'zw_activity_details',
  'zw_activity_photos',
  'zw_activity_streams',
  'zw_segment_efforts'
);

-- Check if policies exist
SELECT 
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN (
  'zw_activities',
  'zw_activity_details',
  'zw_activity_photos',
  'zw_activity_streams',
  'zw_segment_efforts'
)
ORDER BY tablename, policyname;

-- Check table row counts
SELECT
  'zw_activities' AS table_name,
  COUNT(*) AS row_count
FROM zw_activities
UNION ALL
SELECT
  'zw_activity_details' AS table_name,
  COUNT(*) AS row_count
FROM zw_activity_details
UNION ALL
SELECT
  'zw_activity_photos' AS table_name,
  COUNT(*) AS row_count
FROM zw_activity_photos
UNION ALL
SELECT
  'zw_activity_streams' AS table_name,
  COUNT(*) AS row_count
FROM zw_activity_streams
UNION ALL
SELECT
  'zw_segment_efforts' AS table_name,
  COUNT(*) AS row_count
FROM zw_segment_efforts
ORDER BY table_name;
