-- Supabase Migration Script for Zwift Data Viewer
-- Run this script in your Supabase SQL Editor to create the necessary tables

-- Create activities table
CREATE TABLE IF NOT EXISTS zw_activities (
  id BIGINT PRIMARY KEY,
  resource_state INTEGER,
  athlete_id INTEGER,
  name TEXT,
  distance REAL,
  moving_time INTEGER,
  elapsed_time INTEGER,
  total_elevation_gain REAL,
  type TEXT,
  sport_type TEXT,
  start_date TEXT,
  start_date_local TEXT,
  timezone TEXT,
  utc_offset REAL,
  location_city TEXT,
  location_state TEXT,
  location_country TEXT,
  achievement_count INTEGER,
  kudos_count INTEGER,
  comment_count INTEGER,
  athlete_count INTEGER,
  photo_count INTEGER,
  trainer BOOLEAN,
  commute BOOLEAN,
  manual BOOLEAN,
  private BOOLEAN,
  visibility TEXT,
  flagged BOOLEAN,
  gear_id TEXT,
  start_latlng TEXT,
  end_latlng TEXT,
  average_speed REAL,
  max_speed REAL,
  average_cadence REAL,
  average_watts REAL,
  max_watts INTEGER,
  weighted_average_watts INTEGER,
  kilojoules REAL,
  device_watts BOOLEAN,
  has_heartrate BOOLEAN,
  average_heartrate REAL,
  max_heartrate REAL,
  heartrate_opt_out BOOLEAN,
  display_hide_heartrate_option BOOLEAN,
  elev_high REAL,
  elev_low REAL,
  upload_id BIGINT,
  upload_id_str TEXT,
  external_id TEXT,
  from_accepted_tag BOOLEAN,
  pr_count INTEGER,
  total_photo_count INTEGER,
  has_kudoed BOOLEAN,
  json_data TEXT
);

-- Create activity_details table
CREATE TABLE IF NOT EXISTS zw_activity_details (
  id BIGINT PRIMARY KEY,
  json_data TEXT
);

-- Create activity_photos table
CREATE TABLE IF NOT EXISTS zw_activity_photos (
  id SERIAL PRIMARY KEY,
  activity_id BIGINT,
  photo_id TEXT,
  unique_id TEXT,
  json_data TEXT,
  FOREIGN KEY (activity_id) REFERENCES zw_activities (id) ON DELETE CASCADE
);

-- Create activity_streams table
CREATE TABLE IF NOT EXISTS zw_activity_streams (
  id SERIAL PRIMARY KEY,
  activity_id BIGINT,
  json_data TEXT,
  FOREIGN KEY (activity_id) REFERENCES zw_activities (id) ON DELETE CASCADE
);

-- Create segment_efforts table
CREATE TABLE IF NOT EXISTS zw_segment_efforts (
  id SERIAL PRIMARY KEY,
  activity_id BIGINT,
  segment_id INTEGER,
  segment_name TEXT,
  elapsed_time INTEGER,
  moving_time INTEGER,
  start_date TEXT,
  start_date_local TEXT,
  distance REAL,
  start_index INTEGER,
  end_index INTEGER,
  average_watts REAL,
  average_cadence REAL,
  average_heartrate REAL,
  max_heartrate REAL,
  pr_rank INTEGER,
  hidden BOOLEAN,
  elevation_difference REAL,
  average_grade REAL,
  climb_category INTEGER,
  json_data TEXT,
  FOREIGN KEY (activity_id) REFERENCES zw_activities (id) ON DELETE CASCADE
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_zw_activities_start_date ON zw_activities(start_date);
CREATE INDEX IF NOT EXISTS idx_zw_activities_type ON zw_activities(type);
CREATE INDEX IF NOT EXISTS idx_zw_activities_sport_type ON zw_activities(sport_type);
CREATE INDEX IF NOT EXISTS idx_zw_activity_photos_activity_id ON zw_activity_photos(activity_id);
CREATE INDEX IF NOT EXISTS idx_zw_activity_streams_activity_id ON zw_activity_streams(activity_id);
CREATE INDEX IF NOT EXISTS idx_zw_activities_name ON zw_activities(name);
CREATE INDEX IF NOT EXISTS idx_zw_activities_distance ON zw_activities(distance);
CREATE INDEX IF NOT EXISTS idx_zw_activities_moving_time ON zw_activities(moving_time);
CREATE INDEX IF NOT EXISTS idx_zw_activities_total_elevation_gain ON zw_activities(total_elevation_gain);
CREATE INDEX IF NOT EXISTS idx_zw_activities_average_watts ON zw_activities(average_watts);
CREATE INDEX IF NOT EXISTS idx_zw_activities_weighted_average_watts ON zw_activities(weighted_average_watts);
CREATE INDEX IF NOT EXISTS idx_zw_activities_has_heartrate ON zw_activities(has_heartrate);
CREATE INDEX IF NOT EXISTS idx_zw_activity_photos_unique_id ON zw_activity_photos(unique_id);
CREATE INDEX IF NOT EXISTS idx_zw_segment_efforts_activity_id ON zw_segment_efforts(activity_id);
CREATE INDEX IF NOT EXISTS idx_zw_segment_efforts_segment_id ON zw_segment_efforts(segment_id);
CREATE INDEX IF NOT EXISTS idx_zw_segment_efforts_segment_name ON zw_segment_efforts(segment_name);
CREATE INDEX IF NOT EXISTS idx_zw_segment_efforts_elapsed_time ON zw_segment_efforts(elapsed_time);
CREATE INDEX IF NOT EXISTS idx_zw_segment_efforts_start_date ON zw_segment_efforts(start_date);

-- Create Row Level Security (RLS) policies
-- This ensures that users can only access their own data

-- Enable RLS on all tables
ALTER TABLE zw_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE zw_activity_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE zw_activity_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE zw_activity_streams ENABLE ROW LEVEL SECURITY;
ALTER TABLE zw_segment_efforts ENABLE ROW LEVEL SECURITY;

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
