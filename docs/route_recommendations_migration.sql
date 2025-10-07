-- Route Recommendations and User Interactions Migration
-- This script creates the necessary tables for the AI route recommendation system

-- Table for tracking user interactions with specific routes
CREATE TABLE IF NOT EXISTS zw_user_route_interactions (
    id BIGSERIAL PRIMARY KEY,
    route_id INTEGER NOT NULL,
    activity_id BIGINT NOT NULL,
    strava_athlete_id BIGINT NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completion_time_seconds DOUBLE PRECISION,
    average_power DOUBLE PRECISION,
    average_heart_rate DOUBLE PRECISION,
    max_power DOUBLE PRECISION,
    max_heart_rate DOUBLE PRECISION,
    normalized_power DOUBLE PRECISION,
    intensity_factor DOUBLE PRECISION,
    training_stress_score DOUBLE PRECISION,
    average_speed DOUBLE PRECISION,
    max_speed DOUBLE PRECISION,
    elevation_gain DOUBLE PRECISION,
    perceived_effort VARCHAR(20) CHECK (perceived_effort IN ('easy', 'moderate', 'hard', 'very_hard')),
    enjoyment_rating DOUBLE PRECISION CHECK (enjoyment_rating >= 1 AND enjoyment_rating <= 5),
    was_personal_record BOOLEAN DEFAULT FALSE,
    additional_metrics JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign key constraints
    FOREIGN KEY (route_id) REFERENCES zw_routes(id) ON DELETE CASCADE,
    
    -- Unique constraint to prevent duplicate interactions for same activity
    UNIQUE(activity_id, route_id)
);

-- Table for storing route recommendations
CREATE TABLE IF NOT EXISTS zw_route_recommendations (
    id BIGSERIAL PRIMARY KEY,
    strava_athlete_id BIGINT NOT NULL,
    route_id INTEGER NOT NULL,
    confidence_score DOUBLE PRECISION NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 1),
    recommendation_type VARCHAR(50) NOT NULL CHECK (recommendation_type IN ('performance_match', 'progressive_challenge', 'exploration', 'similar_routes')),
    reasoning TEXT NOT NULL,
    scoring_factors JSONB NOT NULL,
    generated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    is_viewed BOOLEAN DEFAULT FALSE,
    is_completed BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 days'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign key constraints
    FOREIGN KEY (route_id) REFERENCES zw_routes(id) ON DELETE CASCADE,
    
    -- Unique constraint to prevent duplicate recommendations
    UNIQUE(strava_athlete_id, route_id, recommendation_type)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_route_interactions_athlete_id ON zw_user_route_interactions(strava_athlete_id);
CREATE INDEX IF NOT EXISTS idx_user_route_interactions_route_id ON zw_user_route_interactions(route_id);
CREATE INDEX IF NOT EXISTS idx_user_route_interactions_completed_at ON zw_user_route_interactions(completed_at);

CREATE INDEX IF NOT EXISTS idx_route_recommendations_athlete_id ON zw_route_recommendations(strava_athlete_id);
CREATE INDEX IF NOT EXISTS idx_route_recommendations_route_id ON zw_route_recommendations(route_id);
CREATE INDEX IF NOT EXISTS idx_route_recommendations_generated_at ON zw_route_recommendations(generated_at);
CREATE INDEX IF NOT EXISTS idx_route_recommendations_confidence_score ON zw_route_recommendations(confidence_score);
CREATE INDEX IF NOT EXISTS idx_route_recommendations_expires_at ON zw_route_recommendations(expires_at);

-- Enable Row Level Security (RLS) for both tables
ALTER TABLE zw_user_route_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE zw_route_recommendations ENABLE ROW LEVEL SECURITY;

-- RLS policies for zw_user_route_interactions
-- Users can only see their own route interactions
CREATE POLICY "Users can view own route interactions" ON zw_user_route_interactions
    FOR SELECT
    USING (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT);

-- Users can insert their own route interactions
CREATE POLICY "Users can insert own route interactions" ON zw_user_route_interactions
    FOR INSERT
    WITH CHECK (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT);

-- Users can update their own route interactions
CREATE POLICY "Users can update own route interactions" ON zw_user_route_interactions
    FOR UPDATE
    USING (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT)
    WITH CHECK (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT);

-- Users can delete their own route interactions
CREATE POLICY "Users can delete own route interactions" ON zw_user_route_interactions
    FOR DELETE
    USING (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT);

-- RLS policies for zw_route_recommendations
-- Users can only see their own recommendations
CREATE POLICY "Users can view own route recommendations" ON zw_route_recommendations
    FOR SELECT
    USING (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT);

-- Users can insert their own recommendations (typically done by system)
CREATE POLICY "Users can insert own route recommendations" ON zw_route_recommendations
    FOR INSERT
    WITH CHECK (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT);

-- Users can update their own recommendations (mark as viewed/completed)
CREATE POLICY "Users can update own route recommendations" ON zw_route_recommendations
    FOR UPDATE
    USING (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT)
    WITH CHECK (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT);

-- Users can delete their own recommendations
CREATE POLICY "Users can delete own route recommendations" ON zw_route_recommendations
    FOR DELETE
    USING (strava_athlete_id = (auth.jwt() ->> 'strava_athlete_id')::BIGINT);

-- Function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to automatically update the updated_at column
CREATE TRIGGER update_zw_user_route_interactions_updated_at
    BEFORE UPDATE ON zw_user_route_interactions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_zw_route_recommendations_updated_at
    BEFORE UPDATE ON zw_route_recommendations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to clean up expired recommendations
CREATE OR REPLACE FUNCTION cleanup_expired_recommendations()
RETURNS void AS $$
BEGIN
    DELETE FROM zw_route_recommendations 
    WHERE expires_at < NOW() AND is_viewed = FALSE;
END;
$$ LANGUAGE plpgsql;

-- Optional: Create a scheduled job to run cleanup (requires pg_cron extension)
-- SELECT cron.schedule('cleanup-expired-recommendations', '0 2 * * *', 'SELECT cleanup_expired_recommendations();');

-- Create some helpful views
CREATE OR REPLACE VIEW v_user_route_performance AS
SELECT 
    uri.strava_athlete_id,
    uri.route_id,
    r.route_name,
    r.world,
    COUNT(*) as completion_count,
    AVG(uri.completion_time_seconds) as avg_completion_time,
    MIN(uri.completion_time_seconds) as best_completion_time,
    AVG(uri.average_power) as avg_power,
    MAX(uri.max_power) as max_power_ever,
    AVG(uri.intensity_factor) as avg_intensity_factor,
    AVG(uri.enjoyment_rating) as avg_enjoyment_rating,
    COUNT(CASE WHEN uri.was_personal_record THEN 1 END) as pr_count,
    MAX(uri.completed_at) as last_completed_at
FROM zw_user_route_interactions uri
JOIN zw_routes r ON uri.route_id = r.id
GROUP BY uri.strava_athlete_id, uri.route_id, r.route_name, r.world;

-- View for active recommendations
CREATE OR REPLACE VIEW v_active_route_recommendations AS
SELECT 
    rr.*,
    r.route_name,
    r.world,
    r.distance_meters,
    r.altitude_meters
FROM zw_route_recommendations rr
JOIN zw_routes r ON rr.route_id = r.id
WHERE rr.expires_at > NOW()
ORDER BY rr.confidence_score DESC, rr.generated_at DESC;

-- Grant necessary permissions (adjust as needed for your setup)
-- GRANT ALL ON zw_user_route_interactions TO authenticated;
-- GRANT ALL ON zw_route_recommendations TO authenticated;
-- GRANT SELECT ON v_user_route_performance TO authenticated;
-- GRANT SELECT ON v_active_route_recommendations TO authenticated;