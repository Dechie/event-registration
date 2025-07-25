# Event Registration System

Event Registration System is a comprehensive Flutter mobile application for event registration with participant management, OTP verification, and QR code generation.

## System Overview

**Purpose**: Enable seamless event registration with participant profile management, session selection, and digital ticket generation, and more.

**Key Features**:

- Multi-step registration form (Personal → Professional → Sessions → OTP)
- Email OTP verification for security
- Session/track selection with capacity management
- Profile photo upload and management
- QR code generation for check-in
- And more

**Target Users**: Event participants and organizers

## Architecture -- How the system is set-up

### Clean Architecture + BLoC Pattern

```
lib/
├── core/                           # Shared utilities
│   ├── constants/                  # App constants & URLs
│   └── network/                    # HTTP client (dio) & network info
├── config/                         # App configuration
│   ├── routes/                     # Navigation & routing
│   └── themes/                     # UI themes & colors
├── features/
│   └── registration/               # Registration feature
│       ├── data/
│       │   ├── datasources/        # Data sources
│       │  └── repositories/       # Repositories with their implementation
│       │
│       └── presentation/
│           ├── bloc/               # State management (BLoC)
│           └── pages/              # UI components
├── injection_container.dart        # Dependency injection
├── app.dart                        # Main App
└── main.dart                       # App entry point
```

### Architecture Layers

**1. Presentation Layer**

- **BLoC**: State management with events/states pattern
- **Pages**: UI components using Material Design 3
- **Theme System**: Centralized styling with light/dark modes

**2. Domain Layer**

- **Repository Contracts**: Abstract interfaces for data access

**3. Data Layer**

- **Models**: Business models (Participant)
- **Repositories and their Implementation**: Abstracting away the data sources
- **Remote DataSource**: API communication via Dio HTTP client

### Key Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3 # State management
  get_it: ^7.6.4 # Dependency injection
  dio: ^5.3.2 # HTTP client
  shared_preferences: ^2.2.1 # Local storage
  internet_connection_checker: ^1.0.0 # Network status
  image_picker: ^1.0.4 # Photo upload
```

### State Management Flow

```
UI Event → BLoC → Repository → DataSource → API/Cache
                     ↓
UI Update ← BLoC ← Repository ← DataSource ← Response
```

### Data Flow (Initial Implementation)

1. **Registration Process**: Personal Info → Professional Info → Session Selection → OTP Verification
2. **Offline Support**: Data cached locally, syncs when online
3. **Error Handling**: Comprehensive error states with user-friendly messages
4. **Network Management**: Automatic offline/online detection and handling

### Design Patterns Used

- **Repository Pattern**: Data access abstraction
- **Dependency Injection**: GetIt for loose coupling
- **BLoC Pattern**: Reactive state management
- **Factory Pattern**: Object creation (fromJson methods)
- **Singleton Pattern**: DioClient HTTP instance

This architecture ensures maintainability, testability, and scalability while providing excellent user experience with offline capabilities and robust error handling. It's based on standard industry practices and is
highly recommended for production ready flutter applications.
