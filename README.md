# Task Manager Application

A modern Task Manager application built with Flutter using Clean Architecture, Bloc state management, and GoRouter for navigation.

## Features

- User Authentication with DummyJSON API
- Task Management (CRUD operations)
- Pagination for efficient data loading
- Local caching with SharedPreferences
- Secure storage for authentication tokens
- Beautiful modern UI with custom theme
- Light/Dark theme support
- Unit tests for critical functionality

## Architecture

The project follows Clean Architecture with clear separation of concerns:

### Layers:

1. **Data Layer**
   - Data Sources (Remote & Local)
   - Models
   - Repositories Implementation

2. **Domain Layer**
   - Entities
   - Repository Interfaces
   - Use Cases

3. **Presentation Layer**
   - BLoC/Cubit for state management
   - Screens
   - Widgets

## State Management

Using BLoC pattern with:
- `SessionBloc` for authentication state
- `TaskListBloc` for task listing with pagination
 

## Navigation

Using GoRouter for declarative routing with:
- Route protection
- Deep linking support
- Named routes
- Smooth transitions

## Dependencies

- `flutter_bloc`: State management
- `dio`: HTTP client
- `get_it`: Dependency injection
- `shared_preferences`: Local storage
- `flutter_secure_storage`: Secure storage
- `go_router`: Navigation
- `equatable`: Value equality

## Setup Instructions

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`

## Testing

Run tests with:
```bash
flutter test