# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Basic Commands
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Code analysis
flutter analyze

# Format code
flutter format .
```

### Build Commands
```bash
# Android production build
flutter build apk --release

# iOS production build
flutter build ios --release

# Web build
flutter build web
```

### Build Scripts
- `./build_with_key_properties.sh` - Android release build with signing
- `./fix_android_studio_permissions.sh` - Fix development environment permissions

## Project Architecture

### Technology Stack
- **Flutter** (>=3.0.0) with Dart (>=2.17.0)
- **Riverpod** (2.3.6) for state management
- **Supabase** (2.9.0) for cloud database and authentication
- **SQLite** (sqflite 2.3.2) for local caching
- **Custom Strava API** package (local path: `../stravaapi`)
- **Syncfusion Charts** (29.2.5) for data visualization
- **Google Gemini AI** (0.4.3) for intelligent route recommendations

### Core Architecture Pattern
**Hybrid Cache-Aside Pattern** with tiered data storage:
1. **Strava API** → Primary data source
2. **Supabase** → Cloud database (source of truth)
3. **SQLite** → Local cache with intelligent optimization
4. **Offline-first** → Seamless online/offline operation

### Key Architectural Files
- `lib/utils/repository/hybrid_activities_repository.dart` - Central data access layer
- `lib/utils/supabase/supabase_database_service.dart` - Supabase integration
- `lib/utils/database/services/activity_service.dart` - Core SQLite operations
- `lib/utils/database/services/segment_effort_service.dart` - Segment data management
- `lib/utils/database/services/route_recommendation_service.dart` - Route recommendation data access
- `lib/utils/storage/tiered_storage_manager.dart` - Storage optimization
- `lib/providers/activities_provider.dart` - Main state management
- `lib/providers/connectivity_provider.dart` - Network status monitoring
- `lib/providers/route_recommendations_provider.dart` - Route recommendation state
- `lib/services/route_recommendation_service.dart` - Intelligent route recommendation algorithms
- `lib/services/gemini_ai_service.dart` - Google Gemini AI integration

### Data Flow
```
Strava API → Supabase (cloud) ↔ SQLite (local) → UI (Riverpod providers)
```

## Database Schema

### SQLite Tables (Local Cache)
- `activities` - Activity summaries
- `activity_details` - Detailed activity data
- `activity_streams` - Time-series data (power, heart rate, etc.)
- `activity_photos` - Photo metadata
- `segment_efforts` - Segment performance data
- `worlds`, `routes`, `climbs` - Zwift world data
- `user_route_interactions` - User engagement with routes (completions, feedback)
- `route_recommendations` - Personalized route recommendations

### Supabase Tables (Cloud Database)
- Mirror structure with `zw_` prefix
- Row Level Security (RLS) based on `strava_athlete_id`
- BIGINT types for Strava IDs
- Migration files in `/docs/` directory (see `route_recommendations_migration.sql`)

## Authentication Flow

### Multi-stage Authentication
1. **Strava OAuth** → Primary authentication
2. **Supabase Auth** → Uses Strava token
3. **Token Management** → Automatic refresh and storage

### Key Authentication Files
- `lib/utils/supabase/supabase_auth_service.dart` - Supabase authentication
- `lib/secrets.dart` - API credentials (configured per environment)

## State Management with Riverpod

### Key Providers
- `activitiesProvider` - Activity data management
- `connectivityProvider` - Network status monitoring
- `configProvider` - User preferences
- `filtersProvider` - Data filtering logic

### Provider Patterns
- **FutureProvider** for async data loading
- **StateNotifierProvider** for mutable state
- **Family providers** for parameterized queries

## Configuration

### Required Configuration
1. **Strava API Credentials** in `lib/secrets.dart`:
   - `CLIENT_ID` - Strava application client ID
   - `CLIENT_SECRET` - Strava application client secret
   - `REDIRECT_URI` - OAuth redirect URI

2. **Google Gemini AI** in `lib/secrets.dart` (optional for route recommendations):
   - `GeminiConfig.apiKey` - Google AI API key
   - `GeminiConfig.model` - Model name (e.g., "gemini-2.0-flash-exp")

3. **Android Signing** (production builds):
   - Environment variables: `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
   - See `android/README.md` for keystore setup

### Optional Configuration
- **Supabase** for cloud sync (setup guide in `/docs/SUPABASE_SETUP.md`)
- **Google Maps API** for route visualization

### Dependency Notes
- **Local Package Dependencies**: The project uses `flutter_strava_api` as a local package (path: `../stravaapi`). Ensure this sibling directory exists.
- **Dependency Overrides**: Extensive overrides in `pubspec.yaml` resolve version conflicts between packages. Modify with caution.

## Code Style and Linting

### Analysis Configuration
- Uses `package:flutter_lints/flutter.yaml`
- Custom rules in `analysis_options.yaml`
- Treats missing required parameters and returns as warnings
- Ignores TODOs
- Prefers const constructors and single quotes

### Important Style Rules
- Use `const` constructors where possible
- Prefer single quotes for strings
- Sort child properties last in widgets
- Avoid print statements (use logging instead)

## Data Synchronization

### Sync Strategy
- **Online Mode**: Supabase primary, SQLite cache
- **Offline Mode**: SQLite only with sync queue
- **Conflict Resolution**: Last-write-wins, Supabase as source of truth

### Sync Services
- `DatabaseSyncService` - Handles bidirectional sync
- `ConnectivityProvider` - Monitors network status
- `TieredStorageManager` - Optimizes local storage

## Testing

### Test Structure
- Basic widget tests in `/test/widget_test.dart`
- Screen-specific tests in `/test/screens/`
- Currently limited test coverage

### Running Tests
```bash
flutter test                    # All tests
flutter test test/widget_test.dart  # Specific test file
flutter test test/screens/      # Screen-specific tests
```

## Development Workflow

### Getting Started
1. Set up Strava API credentials in `lib/secrets.dart`
2. Run `flutter pub get`
3. (Optional) Configure Supabase using `/docs/SUPABASE_SETUP.md`
4. Run `flutter run`

### Key Development Patterns
- **Repository Pattern** for data access
- **Provider Pattern** for state management
- **Offline-first** approach with background sync
- **Tiered Storage** for performance optimization

### Debug Features
- Comprehensive logging in debug mode
- Database status checking
- Connectivity monitoring
- Sync state tracking

## Performance Considerations

### Data Optimization
- **Lazy Loading** of activity details
- **Pagination** for large datasets
- **Tiered Storage** based on access patterns
- **Automatic Cache Cleanup** for memory management

### UI Optimization
- **Riverpod** for efficient state management
- **Syncfusion Charts** for performant data visualization
- **Connectivity Monitoring** for network-aware UI

## AI-Powered Route Recommendations

### Architecture
The app includes an intelligent route recommendation system that combines:
- **Algorithmic Recommendations** (70%): Performance matching, progressive challenge, exploration, similar routes
- **AI Recommendations** (30%): Google Gemini 2.5-powered analysis of user performance patterns

### Key Components
- `IntelligentRouteRecommendationService` - Hybrid recommendation engine
- `GeminiAIService` - AI API integration with prompt engineering
- `RouteRecommendationsProvider` - State management for recommendations
- `UserRouteInteraction` - Tracks user engagement and feedback

### Implementation Details
- Graceful fallback to algorithmic recommendations if AI unavailable
- Cache-aside pattern for recommendation storage
- JSON-structured AI responses parsed into `RouteRecommendation` objects
- See `/docs/AI_INTEGRATION_GUIDE.md` for detailed documentation

## Security Notes

### Data Protection
- Strava API credentials in `lib/secrets.dart` (excluded from version control)
- Google Gemini AI key in `lib/secrets.dart` (excluded from version control)
- Row Level Security (RLS) in Supabase
- Local data encryption through SQLite
- Secure token storage and refresh

### Build Security
- Android keystore management
- Environment variable support for CI/CD
- Proper `.gitignore` for sensitive files