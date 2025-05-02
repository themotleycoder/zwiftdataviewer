# Setting Up Supabase for Zwift Data Viewer

This guide will walk you through the process of setting up Supabase to work with the Zwift Data Viewer app.

## Prerequisites

1. A Supabase account (sign up at [supabase.com](https://supabase.com))
2. A Supabase project (create one from your Supabase dashboard)
3. The Zwift Data Viewer app with Supabase integration

## Step 1: Create the Database Tables

The app requires several tables in your Supabase database to store activity data. You can create these tables by running the SQL migration script provided in the `supabase_migration.sql` file.

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy the contents of the `supabase_migration.sql` file
4. Paste the SQL into the editor
5. Click "Run" to execute the script

This will create the following tables:
- `zw_activities`: Stores summary information about Zwift activities
- `zw_activity_details`: Stores detailed information about specific activities
- `zw_activity_photos`: Stores photos associated with activities
- `zw_activity_streams`: Stores time-series data for activities
- `zw_segment_efforts`: Stores information about segment efforts within activities

It will also set up Row Level Security (RLS) policies to ensure that users can only access their own data.

## Step 2: Configure the App

1. Open the app's `lib/utils/supabase/supabase_config.dart` file
2. Update the `supabaseUrl` and `supabaseAnonKey` values with your Supabase project URL and anon key
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

You can find these values in your Supabase project dashboard under Project Settings > API.

## Step 3: Enable Supabase in the App

1. Launch the Zwift Data Viewer app
2. Go to the Settings screen
3. Toggle "Use Supabase" to ON
4. If prompted, choose "Migrate" to migrate your existing data to Supabase

## Step 4: Verify the Setup

1. In the Settings screen, tap "Sync to Supabase" to manually sync your data
2. Check your Supabase dashboard to verify that data is being stored in the tables

## Troubleshooting

### Tables Don't Exist

If you see errors about tables not existing, make sure you've run the SQL migration script in Step 1.

### Integer Range Error

If you encounter an error like:
```
PostgrestException(message: value "14280515331" is out of range for type integer, code: 22003, details: Bad Request, hint: null)
```

This is because some columns in the database are defined as INTEGER, which has a maximum value of 2,147,483,647. Some Strava IDs (like activity IDs and upload IDs) exceed this limit.

To fix this issue:

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy the contents of the `fix_upload_id_column.sql` file:

```sql
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

-- (Additional policy drops omitted for brevity)

-- Now alter the column types
ALTER TABLE zw_activities ALTER COLUMN id TYPE BIGINT;
ALTER TABLE zw_activities ALTER COLUMN upload_id TYPE BIGINT;
ALTER TABLE zw_activity_details ALTER COLUMN id TYPE BIGINT;
ALTER TABLE zw_activity_photos ALTER COLUMN activity_id TYPE BIGINT;
ALTER TABLE zw_activity_streams ALTER COLUMN activity_id TYPE BIGINT;
ALTER TABLE zw_segment_efforts ALTER COLUMN activity_id TYPE BIGINT;

-- Recreate the policies
-- (Policy recreation statements omitted for brevity)
```

The script first drops all RLS policies, then alters the column types, and finally recreates the policies. This is necessary because PostgreSQL doesn't allow altering columns that are used in policy definitions.

4. Paste the SQL into the editor
5. Click "Run" to execute the script
6. Restart your app and try syncing again

This will alter all relevant columns to use BIGINT instead of INTEGER, allowing them to store much larger values.

If you're setting up a new database, the latest version of `supabase_migration.sql` already uses BIGINT for these columns, so you won't encounter this issue.

### Authentication Issues

If you're having trouble authenticating with Supabase:
1. Make sure your Supabase URL and anon key are correct
2. Check that you're properly authenticated with Strava in the app
3. Verify that the app has permission to access your Strava data

### Sync Issues

If data isn't syncing properly:
1. Check your internet connection
2. Make sure Supabase is enabled in the app settings
3. Try manually syncing by tapping "Sync to Supabase" in the Settings screen
4. Check the app logs for any error messages

## Data Privacy

The Row Level Security (RLS) policies in the migration script ensure that users can only access their own data. Each user's data is associated with their Strava athlete ID, which is stored in their Supabase user metadata when they authenticate.

## Benefits of Using Supabase

- **Cross-device access**: Access your Zwift data from multiple devices
- **Cloud backup**: Your data is safely stored in the cloud
- **Offline support**: The app still works offline, syncing when you're back online
- **Data sharing**: Potential for future features to share data with friends or coaches

## Disabling Supabase

If you want to stop using Supabase:
1. Go to the Settings screen
2. Toggle "Use Supabase" to OFF

The app will continue to use the local SQLite database for all operations.
