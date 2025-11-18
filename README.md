# GRead App

A Flutter application for the GRead social reading platform (gread.fun). This app allows users to track their reading, interact with the community, and manage their book library.

## Features

- **Authentication**
  - User login with JWT token authentication
  - User registration with email activation
  - Secure token storage

- **Activity Feed**
  - View activity stream from the community
  - Post new activity updates
  - Support for book mentions and user mentions
  - Infinite scroll pagination

- **User Profiles**
  - View user profiles
  - Display reading statistics
  - Show achievements and favorite genres

- **Library Management**
  - View personal book library
  - Track reading progress
  - Update current page for books
  - Filter books by status (reading, completed, want to read)
  - Add and remove books from library

- **Book Search**
  - Search books by title or author
  - Import books via ISBN
  - View detailed book information
  - Add books to library

## API Integration

This app integrates with two APIs:

1. **GRead Custom API** (`gread/v1`)
   - User statistics
   - Library management
   - Book search and ISBN lookup
   - Activity feed
   - Achievements system

2. **BuddyPress API** (`buddypress/v1`)
   - User authentication
   - Member profiles
   - Social features

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Flutter-Test
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:

For Android:
```bash
flutter run -d android
```

For Web:
```bash
flutter run -d chrome
```

## Platform Support

This app is configured to run on:
- ✅ Android
- ✅ Web (Chrome/Browser)

The following platforms are intentionally disabled:
- ❌ iOS
- ❌ macOS
- ❌ Windows
- ❌ Linux

## Project Structure

```
lib/
├── config/          # API configuration
├── models/          # Data models
├── providers/       # State management (Provider)
├── screens/         # UI screens
│   ├── auth/       # Login & Registration
│   ├── activity/   # Activity feed
│   ├── library/    # Library management
│   ├── profile/    # User profiles
│   └── search/     # Book search
├── services/        # API and storage services
├── utils/           # Utility functions
└── widgets/         # Reusable widgets
```

## API Documentation

For detailed API documentation, see:
- `GREAD_API_GUIDE.md` - GRead custom API endpoints
- `BUDDYPRESS_API_GUIDE.md` - BuddyPress API endpoints

## Dependencies

- **provider**: State management
- **http**: HTTP requests
- **shared_preferences**: Local data storage

## Testing

The app can be tested on:

1. **Android Device/Emulator**:
   ```bash
   flutter run -d android
   ```

2. **Web Browser**:
   ```bash
   flutter run -d chrome
   ```

## Architecture

The app follows a clean architecture pattern:

- **Models**: Data structures for API responses
- **Services**: API communication and data persistence
- **Providers**: State management using Provider pattern
- **Screens**: UI layer organized by feature
- **Widgets**: Reusable UI components

## Features by Screen

### Login/Registration
- JWT authentication
- Form validation
- Error handling
- Auto-login on app start

### Activity Feed
- Infinite scroll
- Pull to refresh
- Post new activities
- Display comments

### Library
- Filter by status
- Update reading progress
- Remove books
- Statistics display

### Book Search
- Text search
- ISBN lookup
- Add to library
- View book details

### Profile
- Display user info
- Show reading stats
- View achievements (when available)

## Notes

- The app requires an active internet connection
- All API requests are authenticated via JWT tokens
- User data is stored locally for offline access to credentials

## License

This project is part of the GRead platform.

## Contact

For issues or questions about the GRead platform, visit https://gread.fun
