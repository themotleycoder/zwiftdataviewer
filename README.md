# zwiftdataviewer

## Background

I wanted to learn Flutter and decided to combine this opportunity with the chance to buuld an app that could better visaulize my stats from riding in Zwift. Unfortunelty Zwift has a closed API! However after some digging I realized I could pull the required data from Zwift via my Strava account, Strava has an API.

## Pre-reqs
- Strava developer account
- Flutter/Dart installed
- IDE to code in - I use Android Developer Studio because I am coding on linux and deploying to an Android device and so cant build a iOS version 

## Getting Started
1. Pull the code down
2. In the `project_root/lib` directory create a file called 'secrets.dart'
3. Paste (or type) the following into the file:

```
final String secret = "strava_secret";
final String clientId = "strava_client";
```

4. Replace placeholders (strava_secret, strava_client) with your Strava developer API information
5. Compile and run!
