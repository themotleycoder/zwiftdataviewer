# Android Build Instructions

## Building for Production

To build the app for production, follow these steps:

1. Ensure you have the keystore file in place:
   - The keystore file should be located at `android/keystore/release-keystore.jks`
   - If you don't have this file, you can generate it using the following command:
     ```
     keytool -genkey -v -keystore android/keystore/release-keystore.jks -alias release -keyalg RSA -keysize 2048 -validity 10000 -storepass keystore_password -keypass key_password -dname "CN=Zwift Data Viewer, OU=Development, O=MotleyCoder, L=Unknown, S=Unknown, C=US"
     ```

2. Set up keystore credentials:
   - Option 1: Set environment variables:
     ```
     export KEYSTORE_PASSWORD=keystore_password
     export KEY_ALIAS=release
     export KEY_PASSWORD=key_password
     ```
   - Option 2: Update the `android/app/build.gradle` file with your actual keystore credentials (not recommended for security reasons)

3. Build the APK:
   ```
   flutter build apk --release
   ```

4. The APK will be generated at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

## Notes

- The app is configured to use minification and shrinking for release builds
- ProGuard rules are defined in `android/app/proguard-rules.pro`
- Make sure to test the release build thoroughly before distribution
- For app store distribution, you may want to use `flutter build appbundle` instead

## Security Considerations

- Keep your keystore file and passwords secure
- Do not commit the keystore file or passwords to version control
- Consider using a CI/CD system with secure environment variables for automated builds
