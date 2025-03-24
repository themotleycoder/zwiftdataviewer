# Contributing to Zwift Data Viewer

Thank you for considering contributing to Zwift Data Viewer! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

Please be respectful and considerate of others when contributing to this project. We aim to foster an inclusive and welcoming community.

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with the following information:

1. A clear, descriptive title
2. Steps to reproduce the bug
3. Expected behavior
4. Actual behavior
5. Screenshots (if applicable)
6. Device information (OS, Flutter version, etc.)

### Suggesting Features

If you have an idea for a new feature, please create an issue with the following information:

1. A clear, descriptive title
2. A detailed description of the feature
3. Why this feature would be useful
4. Any implementation ideas you have

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Make your changes
4. Run tests and ensure they pass
5. Submit a pull request

## Development Setup

1. Install Flutter and Dart SDKs
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Coding Guidelines

### Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Keep functions small and focused on a single responsibility

### Architecture

The application follows a clean architecture approach with the following layers:

1. **UI Layer** (screens, widgets): Responsible for displaying data and handling user interactions.
2. **State Management Layer** (providers): Manages the application state using Riverpod.
3. **Domain Layer** (models): Contains the business logic and data models.
4. **Data Layer** (repositories): Handles data fetching and persistence.

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

## Pull Request Process

1. Ensure your code follows the coding guidelines
2. Update the documentation if necessary
3. Add tests for your changes
4. Make sure all tests pass
5. Submit your pull request with a clear description of the changes

## Review Process

1. At least one maintainer will review your pull request
2. Feedback may be provided for changes or improvements
3. Once approved, your pull request will be merged

## License

By contributing to this project, you agree that your contributions will be licensed under the project's MIT License.
