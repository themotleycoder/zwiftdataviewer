# Zwift Data Viewer

A Flutter application for viewing and analyzing Zwift data, including activities, routes, and world schedules.

## Features

- View Zwift activities and statistics
- Browse Zwift routes with detailed information
- Check the Zwift world calendar to see which worlds are available on specific days
- Analyze ride data with charts and statistics

## Project Structure

The project follows a feature-based structure with clear separation of concerns:

```
lib/
  ├── delegates/         # Search delegates for filtering data
  ├── models/            # Data models representing domain entities
  ├── providers/         # State management using Riverpod
  │   └── filters/       # Providers for filtering data
  ├── screens/           # UI screens organized by feature
  │   ├── allstats/      # Statistics screens
  │   ├── calendars/     # Calendar screens
  │   ├── layouts/       # Layout templates
  │   └── routestats/    # Route statistics screens
  ├── utils/             # Utility functions and constants
  │   └── repository/    # Data repositories for fetching and storing data
  └── widgets/           # Reusable UI components
```

## Architecture

The application follows a clean architecture approach with the following layers:

1. **UI Layer** (screens, widgets): Responsible for displaying data and handling user interactions.
2. **State Management Layer** (providers): Manages the application state using Riverpod.
3. **Domain Layer** (models): Contains the business logic and data models.
4. **Data Layer** (repositories): Handles data fetching and persistence.

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/zwiftdataviewer.git
   ```

2. Navigate to the project directory:
   ```
   cd zwiftdataviewer
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Development Guidelines

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions small and focused on a single responsibility

### State Management

- Use Riverpod for state management
- Create providers for each distinct piece of state
- Use StateNotifier for complex state that changes over time
- Use FutureProvider for asynchronous data loading

### Error Handling

- Handle errors gracefully with user-friendly error messages
- Use try-catch blocks for error-prone operations
- Log errors for debugging purposes
- Provide retry mechanisms where appropriate

### Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Use integration tests for end-to-end testing

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
