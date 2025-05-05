-- Migration Script for Zwift Data Viewer - Worlds, Routes, and Climbs Tables
-- Run this script in your Supabase SQL Editor to create the necessary tables

-- Create worlds table
CREATE TABLE IF NOT EXISTS zw_worlds (
  id INTEGER PRIMARY KEY,
  name TEXT,
  url TEXT,
  json_data TEXT,
  athlete_id INTEGER
);

-- Create routes table
CREATE TABLE IF NOT EXISTS zw_routes (
  id INTEGER PRIMARY KEY,
  url TEXT,
  world TEXT, -- Kept for backward compatibility
  distance_meters REAL,
  altitude_meters REAL,
  event_only TEXT,
  route_name TEXT,
  completed BOOLEAN DEFAULT FALSE,
  image_id INTEGER,
  json_data TEXT,
  athlete_id INTEGER
);

-- Add world_id column to routes table
ALTER TABLE zw_routes ADD COLUMN IF NOT EXISTS world_id INTEGER REFERENCES zw_worlds(id);

-- Create climbs table
CREATE TABLE IF NOT EXISTS zw_climbs (
  id INTEGER PRIMARY KEY,
  climb_id INTEGER,
  name TEXT,
  url TEXT,
  json_data TEXT,
  athlete_id INTEGER
);

-- Add world_id column to climbs table
ALTER TABLE zw_climbs ADD COLUMN IF NOT EXISTS world_id INTEGER REFERENCES zw_worlds(id);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_zw_worlds_name ON zw_worlds(name);
CREATE INDEX IF NOT EXISTS idx_zw_worlds_athlete_id ON zw_worlds(athlete_id);
CREATE INDEX IF NOT EXISTS idx_zw_routes_world ON zw_routes(world);
CREATE INDEX IF NOT EXISTS idx_zw_routes_route_name ON zw_routes(route_name);
CREATE INDEX IF NOT EXISTS idx_zw_routes_distance_meters ON zw_routes(distance_meters);
CREATE INDEX IF NOT EXISTS idx_zw_routes_altitude_meters ON zw_routes(altitude_meters);
CREATE INDEX IF NOT EXISTS idx_zw_routes_completed ON zw_routes(completed);
CREATE INDEX IF NOT EXISTS idx_zw_routes_athlete_id ON zw_routes(athlete_id);
CREATE INDEX IF NOT EXISTS idx_zw_climbs_name ON zw_climbs(name);
CREATE INDEX IF NOT EXISTS idx_zw_climbs_climb_id ON zw_climbs(climb_id);
CREATE INDEX IF NOT EXISTS idx_zw_climbs_athlete_id ON zw_climbs(athlete_id);

-- Create indexes for world_id columns
CREATE INDEX IF NOT EXISTS idx_zw_routes_world_id ON zw_routes(world_id);
CREATE INDEX IF NOT EXISTS idx_zw_climbs_world_id ON zw_climbs(world_id);

-- Enable Row Level Security (RLS) on tables
ALTER TABLE zw_worlds ENABLE ROW LEVEL SECURITY;
ALTER TABLE zw_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE zw_climbs ENABLE ROW LEVEL SECURITY;

-- Create policies for worlds table
CREATE POLICY zw_worlds_select_policy ON zw_worlds
  FOR SELECT USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_worlds_insert_policy ON zw_worlds
  FOR INSERT WITH CHECK (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_worlds_update_policy ON zw_worlds
  FOR UPDATE USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_worlds_delete_policy ON zw_worlds
  FOR DELETE USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

-- Create policies for routes table
CREATE POLICY zw_routes_select_policy ON zw_routes
  FOR SELECT USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_routes_insert_policy ON zw_routes
  FOR INSERT WITH CHECK (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_routes_update_policy ON zw_routes
  FOR UPDATE USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_routes_delete_policy ON zw_routes
  FOR DELETE USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

-- Create policies for climbs table
CREATE POLICY zw_climbs_select_policy ON zw_climbs
  FOR SELECT USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_climbs_insert_policy ON zw_climbs
  FOR INSERT WITH CHECK (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_climbs_update_policy ON zw_climbs
  FOR UPDATE USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));

CREATE POLICY zw_climbs_delete_policy ON zw_climbs
  FOR DELETE USING (athlete_id = ((auth.jwt() -> 'user_metadata' ->> 'strava_athlete_id')::integer));
