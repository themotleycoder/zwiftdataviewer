# Zwift Data Viewer

A Flutter application for viewing and analyzing Zwift data.

## Getting Started

This project is a Flutter application that uses the Strava API to fetch and display Zwift activity data.

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Android Studio or Visual Studio Code with Flutter extensions
- A Strava API account for authentication

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/zwiftdataviewer.git
   cd zwiftdataviewer
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Configure Strava API credentials:
   - Edit the `lib/secrets.dart` file with your Strava API credentials
   - Replace the placeholder values with your actual Strava Client ID and Client Secret

## Building for Production

### Android

To build the app for production on Android, follow these steps:

1. Ensure you have set up the keystore for signing:
   - See the instructions in `android/README.md` for details on setting up the keystore and signing configuration

2. Set up environment variables for the keystore:
   ```
   export KEYSTORE_PASSWORD=your_keystore_password
   export KEY_ALIAS=your_key_alias
   export KEY_PASSWORD=your_key_password
   ```

3. Build the APK:
   ```
   flutter build apk --release
   ```

4. The APK will be generated at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

### iOS

To build the app for production on iOS, follow these steps:

1. Open the iOS project in Xcode:
   ```
   open ios/Runner.xcworkspace
   ```

2. Configure signing in Xcode:
   - Select the Runner project in the Project Navigator
   - Select the Runner target
   - Go to the Signing & Capabilities tab
   - Select your team and configure signing

3. Build the app:
   ```
   flutter build ios --release
   ```

4. Archive the app in Xcode for distribution

## Features

- View Zwift activities
- Analyze ride data including power, heart rate, and elevation
- View Zwift routes and climb information
- Calendar view of Zwift events
- Customizable settings including FTP and measurement units

## Security Considerations

- Strava API credentials are hardcoded in the `lib/secrets.dart` file, which should be kept secure and not committed to version control (it's included in .gitignore)
- For production builds, ensure you replace the placeholder credentials with your actual Strava API credentials
- The keystore file for Android signing should be kept secure and not committed to version control

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the terms found in the LICENSE file.
