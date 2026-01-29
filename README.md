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

## Screenshots


<img width="341" height="695" alt="image" src="https://github.com/user-attachments/assets/998e66f1-9074-40ab-b515-0dc5dcb16cfd" />




<img width="334" height="703" alt="image" src="https://github.com/user-attachments/assets/8cf1fb64-c5da-4952-8cdf-c765065f4f87" />


<img width="346" height="696" alt="image" src="https://github.com/user-attachments/assets/4df8db09-5346-4c50-91a4-ddc016992b63" />


<img width="343" height="536" alt="image" src="https://github.com/user-attachments/assets/b94c4c57-fb50-4d00-b472-d649bced7ffe" />



<img width="339" height="704" alt="image" src="https://github.com/user-attachments/assets/c06b0896-5dc7-4549-8714-ef6cf41c635b" />





 
