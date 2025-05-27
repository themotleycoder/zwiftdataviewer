# iOS Post-Authentication App Reload Fix

## Problem Description
The post-auth step of reloading the app after authorization was failing on iOS. This was causing the app to not properly refresh data after successful Strava authentication.

## Root Causes Identified

1. **Missing URL Scheme Configuration**: The iOS app didn't have proper URL scheme configuration for handling redirects from external authentication flows.

2. **No App Lifecycle Handling**: The app wasn't properly handling the transition back from external browser authentication.

3. **Missing Data Provider Invalidation**: After successful authentication, the app wasn't invalidating and refreshing the data providers.

## Solutions Implemented

### 1. iOS Configuration Updates

#### Info.plist Changes
- Added `CFBundleURLTypes` configuration to handle custom URL schemes
- Added `LSApplicationQueriesSchemes` to allow querying for Strava and web URLs
- Configured `zwiftdataviewer://` as the custom URL scheme

#### AppDelegate.swift Updates
- Added URL scheme handling in `application(_:open:options:)`
- Added app lifecycle event handling with `applicationDidBecomeActive` and `applicationWillResignActive`
- Implemented Flutter method channel communication for lifecycle events

### 2. Flutter App Lifecycle Service

#### New AppLifecycleService (`lib/utils/app_lifecycle_service.dart`)
- Created a service to handle iOS app lifecycle events via method channels
- Provides a stream of lifecycle events that can be listened to by providers
- Initializes method channel handlers for iOS lifecycle callbacks

### 3. Post-Authentication Data Refresh

#### New PostAuthRefreshProvider (`lib/providers/post_auth_refresh_provider.dart`)
- Listens to app lifecycle events
- Automatically invalidates data providers when app becomes active
- Triggers background sync when returning from external authentication
- Provides manual refresh functionality

#### Updated StravaApiHelper
- Added automatic data refresh trigger after successful authentication
- Integrated with the post-auth refresh provider
- Ensures data is refreshed immediately after authentication completes

### 4. Integration Points

#### HomeScreen Updates
- Initialized the post-auth refresh provider to start listening for lifecycle events
- Ensures the refresh mechanism is active from app startup

#### Main App Updates
- Added AppLifecycleService initialization during app startup
- Ensures lifecycle monitoring starts early in the app lifecycle

## How It Works

1. **User initiates authentication**: User taps to authenticate with Strava
2. **External browser opens**: App launches Safari/Chrome for Strava login
3. **User completes authentication**: User enters credentials and email verification code
4. **App returns to foreground**: iOS calls `applicationDidBecomeActive`
5. **Lifecycle event triggered**: AppDelegate sends event to Flutter via method channel
6. **Data refresh initiated**: PostAuthRefreshProvider receives event and invalidates providers
7. **UI updates**: Home screen and other components automatically refresh with new data

## Files Modified

### iOS Native Files
- `ios/Runner/Info.plist` - Added URL schemes and query schemes
- `ios/Runner/AppDelegate.swift` - Added lifecycle and URL handling

### Flutter Files
- `lib/utils/app_lifecycle_service.dart` - New lifecycle service
- `lib/providers/post_auth_refresh_provider.dart` - New refresh provider
- `lib/main.dart` - Added lifecycle service initialization
- `lib/screens/homescreen.dart` - Added refresh provider initialization
- `lib/utils/strava_api_helper.dart` - Added post-auth refresh trigger
- `lib/screens/strava_email_auth_screen.dart` - Minor cleanup

## Testing

To test the fix:

1. Clear any existing Strava tokens from the app
2. Navigate to a screen that requires Strava data
3. Trigger authentication flow
4. Complete authentication in external browser
5. Return to app
6. Verify that data loads automatically without manual refresh

## Benefits

- **Seamless user experience**: No manual refresh required after authentication
- **Automatic data sync**: App automatically fetches latest data when returning from auth
- **Robust error handling**: Graceful fallback if refresh fails
- **iOS-specific optimizations**: Leverages iOS app lifecycle events for better integration

## Future Improvements

- Could extend to Android with similar lifecycle handling
- Could add more granular refresh controls (e.g., only refresh specific data types)
- Could implement retry logic for failed background syncs
- Could add user feedback during background refresh operations
