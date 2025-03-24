/// This file contains sensitive information that should not be committed to version control.
/// Make sure this file is added to .gitignore.

class Secrets {
  // Strava API credentials
  static const String clientId = '51015'; // Replace with your actual Strava client ID
  static const String clientSecret = 'ba4a416ac3207bc4dc2fbe75793a14516fc9c992'; // Replace with your actual Strava client secret
}

// Global variables for backward compatibility
// These will be used by existing code until it's updated to use Secrets class directly
const String client_id = Secrets.clientId;
const String client_secret = Secrets.clientSecret;
