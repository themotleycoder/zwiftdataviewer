-- Fix for integer columns in Supabase tables
-- This migration changes column types from INTEGER to BIGINT
-- to accommodate larger values like 14280515331

-- First, drop all policies that depend on the columns we want to alter
DROP POLICY IF EXISTS zw_activities_select_policy ON zw_activities;
DROP POLICY IF EXISTS zw_activities_insert_policy ON zw_activities;
DROP POLICY IF EXISTS zw_activities_update_policy ON zw_activities;
DROP POLICY IF EXISTS zw_activities_delete_policy ON zw_activities;

DROP POLICY IF EXISTS zw_activity_details_select_policy ON zw_activity_details;
DROP POLICY IF EXISTS zw_activity_details_insert_policy ON zw_activity_details;
DROP POLICY IF EXISTS zw_activity_details_update_policy ON zw_activity_details;
DROP POLICY IF EXISTS zw_activity_details_delete_policy ON zw_activity_details;

DROP POLICY IF EXISTS zw_activity_photos_select_policy ON zw_activity_photos;
DROP POLICY IF EXISTS zw_activity_photos_insert_policy ON zw_activity_photos;
DROP POLICY IF EXISTS zw_activity_photos_update_policy ON zw_activity_photos;
DROP POLICY IF EXISTS zw_activity_photos_delete_policy ON zw_activity_photos;

DROP POLICY IF EXISTS zw_activity_streams_select_policy ON zw_activity_streams;
DROP POLICY IF EXISTS zw_activity_streams_insert_policy ON zw_activity_streams;
DROP POLICY IF EXISTS zw_activity_streams_update_policy ON zw_activity_streams;
DROP POLICY IF EXISTS zw_activity_streams_delete_policy ON zw_activity_streams;

DROP POLICY IF EXISTS zw_segment_efforts_select_policy ON zw_segment_efforts;
DROP POLICY IF EXISTS zw_segment_efforts_insert_policy ON zw_segment_efforts;
DROP POLICY IF EXISTS zw_segment_efforts_update_policy ON zw_segment_efforts;
DROP POLICY IF EXISTS zw_segment_efforts_delete_policy ON zw_segment_efforts;

-- Now alter the column types
ALTER TABLE zw_activities ALTER COLUMN id TYPE BIGINT;
ALTER TABLE zw_activities ALTER COLUMN upload_id TYPE BIGINT;
ALTER TABLE zw_activity_details ALTER COLUMN id TYPE BIGINT;
ALTER TABLE zw_activity_photos ALTER COLUMN activity_id TYPE BIGINT;
ALTER TABLE zw_activity_streams ALTER COLUMN activity_id TYPE BIGINT;
ALTER TABLE zw_segment_efforts ALTER COLUMN activity_id TYPE BIGINT;

-- Recreate the policies
-- Create policies for activities table
CREATE POLICY zw_activities_select_policy ON zw_activities
  FOR SELECT USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_activities_insert_policy ON zw_activities
  FOR INSERT WITH CHECK (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_activities_update_policy ON zw_activities
  FOR UPDATE USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_activities_delete_policy ON zw_activities
  FOR DELETE USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

-- Create policies for activity_details table
CREATE POLICY zw_activity_details_select_policy ON zw_activity_details
  FOR SELECT USING (
    id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_activity_details_insert_policy ON zw_activity_details
  FOR INSERT WITH CHECK (
    id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_activity_details_update_policy ON zw_activity_details
  FOR UPDATE USING (
    id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_activity_details_delete_policy ON zw_activity_details
  FOR DELETE USING (
    id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

-- Create policies for activity_photos table
CREATE POLICY zw_activity_photos_select_policy ON zw_activity_photos
  FOR SELECT USING (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_activity_photos_insert_policy ON zw_activity_photos
  FOR INSERT WITH CHECK (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_activity_photos_update_policy ON zw_activity_photos
  FOR UPDATE USING (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_activity_photos_delete_policy ON zw_activity_photos
  FOR DELETE USING (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

-- Create policies for activity_streams table
CREATE POLICY zw_activity_streams_select_policy ON zw_activity_streams
  FOR SELECT USING (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_activity_streams_insert_policy ON zw_activity_streams
  FOR INSERT WITH CHECK (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_activity_streams_update_policy ON zw_activity_streams
  FOR UPDATE USING (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_activity_streams_delete_policy ON zw_activity_streams
  FOR DELETE USING (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

-- Create policies for segment_efforts table
CREATE POLICY zw_segment_efforts_select_policy ON zw_segment_efforts
  FOR SELECT USING (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_segment_efforts_insert_policy ON zw_segment_efforts
  FOR INSERT WITH CHECK (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_segment_efforts_update_policy ON zw_segment_efforts
  FOR UPDATE USING (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

CREATE POLICY zw_segment_efforts_delete_policy ON zw_segment_efforts
  FOR DELETE USING (
    activity_id IN (SELECT id FROM zw_activities WHERE athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer))
  );

-- Verify the changes
SELECT 
  table_name,
  column_name, 
  data_type 
FROM 
  information_schema.columns 
WHERE 
  table_schema = 'public' 
  AND table_name IN ('zw_activities', 'zw_activity_details', 'zw_activity_photos', 'zw_activity_streams', 'zw_segment_efforts')
  AND column_name IN ('id', 'activity_id', 'upload_id')
ORDER BY table_name, column_name;
