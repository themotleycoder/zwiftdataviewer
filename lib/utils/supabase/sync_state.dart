/// Synchronization state
///
/// This enum represents the current state of the synchronization process.
enum SyncState {
  /// No synchronization is in progress
  idle,

  /// Initial migration is in progress
  migrating,

  /// Synchronizing pending changes from SQLite to Supabase
  syncingToSupabase,

  /// Synchronizing data from Supabase to SQLite cache
  syncingFromSupabase,

  /// Synchronization completed successfully
  completed,

  /// An error occurred during synchronization
  error,
}
