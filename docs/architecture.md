# Architectural Overview of Zwift Data Viewer

## Data Flow Architecture

The Zwift Data Viewer app employs a streamlined data architecture with several data sources and a tiered storage approach. Here's how the app connects to and retrieves data:

### 1. Data Sources

The app retrieves data from three primary sources:

- **Strava API**: The primary source of activity data. The app authenticates with Strava and fetches virtual ride activities.
- **Local SQLite Database**: Stores a local copy of all activities and related data for offline access.
- **Supabase Cloud Database**: Provides cloud storage and synchronization capabilities for activities across devices.
- **Web Scraping**: For supplementary data like Zwift routes and world calendars from Zwift Insider.

### 2. Authentication Flow

**Strava Authentication**:
- On app startup, the app attempts to authenticate with Strava using stored tokens
- If tokens are expired, it attempts to refresh them
- If refresh fails, it prompts the user for authentication
- The app uses OAuth to obtain access and refresh tokens from Strava

**Supabase Authentication**:
- After successful Strava authentication, the app uses the Strava token to authenticate with Supabase
- This creates a link between the user's Strava account and their Supabase account
- Authentication state is persisted in SharedPreferences for restoration across app restarts

### 3. Data Retrieval Flow

The app follows this sequence when retrieving data:

**Initial Data Load**:
- The app first checks connectivity status via `ConnectivityProvider`
- If online, it attempts to fetch new activities from Strava API via `stravaActivitiesProvider`
- Activities are filtered to include only `VirtualRide` type activities (Zwift rides)
- New activities are stored in Supabase first, then cached in SQLite with optimized storage

**Cache-Aside Repository Pattern**:
- The `HybridActivitiesRepository` is the central component managing data access
- It implements a cache-aside pattern with Supabase as the system of record and SQLite as a local cache
- When retrieving data, it follows this simplified flow:
  1. If online and Supabase is enabled, fetch from Supabase and cache in SQLite
  2. If offline or Supabase fetch fails, serve from SQLite cache
  3. Data is always cached in SQLite for offline access

**Tiered Storage Approach**:
- The `TieredStorageManager` optimizes local storage based on access patterns
- Frequently accessed data is prioritized in SQLite storage
- Less frequently accessed data may be stored only in Supabase
- The manager tracks access frequency and recency to make intelligent caching decisions
- Storage is automatically optimized to keep the SQLite database size manageable

**Unidirectional Data Flow**:
- The app implements a unidirectional data flow where Supabase is the source of truth
- Data is always written to Supabase first (when online), then cached in SQLite
- This simplifies the data flow and reduces potential for conflicts
- When offline, changes are made to SQLite and synced to Supabase when back online

### 4. Storage Hierarchy and Optimization Strategy

The app uses a tiered approach to data storage with intelligent caching:

**Primary Data Path (Online Mode)**:
- Strava API → Supabase → SQLite (with tiered storage optimization)
- Retrieval: Supabase → SQLite cache (when offline or as fallback)

**Tiered Storage Strategy**:
- Recently and frequently accessed activities are prioritized in SQLite
- Activities with high access scores keep more associated data (photos, streams, segment efforts)
- Older and less frequently accessed data may be pruned from SQLite but remains in Supabase
- The system automatically balances storage needs with performance requirements

**Offline Mode Path**:
- SQLite cache for retrieval
- Changes are made to SQLite and synced to Supabase when back online

**Supplementary Data (Routes, World Calendar)**:
- Web scraping → Local JSON files
- Retrieval: Local JSON files → Web scraping (if files don't exist or are outdated)

### 5. Data Models and Transformations

The app uses several data models that are transformed between different layers:

- **API Models**: From Strava API (SummaryActivity, DetailedActivity, etc.)
- **Database Models**: For SQLite and Supabase storage (ActivityModel, ActivityDetailModel, etc.)
- **UI Models**: For presentation in the app

Data transformations occur at repository boundaries, with methods like `toSummaryActivity()` and `fromSummaryActivity()` handling conversions.

### 6. Configuration Management

The app manages configuration through:

- **ConfigProvider**: Stores user preferences like units (metric/imperial) and FTP
- **FileRepository**: Handles saving and loading configuration to/from local storage

## Complete Data Flow Sequence

1. User opens app → App initializes database, Supabase, and TieredStorageManager
2. App authenticates with Strava → Uses token to authenticate with Supabase
3. App checks connectivity → Determines online/offline mode
4. App loads activities:
   - If online: Fetches new activities from Strava API, stores in Supabase, then caches in SQLite with optimized storage
   - Retrieves activities from Supabase (if online) or SQLite cache (if offline)
5. App loads supplementary data (routes, world calendar) from local files or web scraping
6. TieredStorageManager continuously optimizes SQLite storage based on usage patterns
7. When connectivity changes:
   - Online → Offline: App continues to work with local SQLite cache
   - Offline → Online: App syncs local changes to Supabase (source of truth)

This architecture ensures the app works seamlessly in both online and offline scenarios while maintaining data consistency across devices through cloud synchronization. The tiered storage approach optimizes device storage usage while still providing excellent performance and offline capabilities.
