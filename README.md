# Sokrio People Pulse

A Flutter mobile application that demonstrates advanced state management, clean architecture, and robust user management features. This app fetches and displays a list of users from a public API with comprehensive functionality including search, pagination, caching, and offline capabilities.

## 📦 Repository
- **GitHub**: [https://github.com/AAShayon/sokrio_test.git](https://github.com/AAShayon/sokrio_test.git)

## 🚀 Features

### Core Functionality
- **User List Screen**: Displays a list of users with their profile pictures and names
- **User Detail Screen**: Shows detailed user information including profile picture, name, email, and phone number
- **Search Functionality**: Implements local search filtering with offline capability
- **Pagination**: Infinite scrolling with API pagination support
- **Pull to Refresh**: Fresh content retrieval with gesture-based refresh
- **Offline Support**: Works seamlessly without internet connection using local caching

### Technical Highlights
- **State Management**: Built with Riverpod for predictable state management
- **Clean Architecture**: Clear separation of concerns (data, domain, presentation layers)
- **Dependency Injection**: Uses get_it for proper service management
- **Local Database**: Drift SQLite for offline-first data persistence
- **Responsive Design**: Adapts to different screen sizes using Flutter ScreenUtil
- **Error Handling**: Comprehensive error states and user feedback

## 🏗️ Architecture

This project follows the Clean Architecture pattern with three distinct layers:

### Presentation Layer
- **Widgets**: UI components built with Flutter
- **Providers**: Riverpod notifiers for state management
- **Routes**: Navigation handled by GoRouter

### Domain Layer
- **Entities**: Business objects representing core business concepts
- **Use Cases**: Business logic encapsulated in repositories
- **Repositories**: Abstract interfaces for data sources

### Data Layer
- **Models**: Data classes with serialization
- **Data Sources**: Remote API and local database access
- **Repositories**: Concrete implementations of domain repositories

## 🛠️ Technologies Used

### State Management
- **Riverpod**: Predictable and scalable state management solution

### Networking
- **Dio**: HTTP client library with advanced features
- **Connectivity Plus**: Network status detection

### Data Persistence
- **Drift**: Type-safe SQL database for Flutter with reactive streams
- **SQLite**: Local database engine with efficient querying
- **Path Provider**: File system path utilities
- **Cache Strategy**: Immediate display of cached data when app starts without internet

### Dependency Management
- **get_it**: Service locator for dependency injection

### UI Components
- **GoRouter**: Declarative routing solution
- **Flutter ScreenUtil**: Responsive UI scaling
- **Cached Network Image**: Optimized image loading
- **Shimmer**: Loading placeholders for better UX

### Functional Programming
- **Dartz**: Functional programming tools for error handling
- **Equatable**: Value-based equality comparisons

### Code Generation
- **Freezed**: Immutable data classes with copy methods
- **Json Serializable**: Automatic JSON serialization

## 📋 Project Structure

```
lib/
├── app/
│   ├── core/
│   │   ├── config/
│   │   ├── di/           # Dependency injection setup
│   │   ├── error/        # Error handling classes
│   │   ├── network/      # Network utilities
│   │   ├── theme/        # App themes
│   │   └── utils/        # Utility functions
│   └── features/
│       └── users/        # Feature module following Clean Architecture
│           ├── data/     # Data layer (models, datasources, repos)
│           ├── domain/   # Domain layer (entities, repositories, usecases)
│           └── presentation/ # Presentation layer (screens, widgets, providers)
```

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.2.0 or higher)
- Dart SDK (3.2.0 or higher)

### Installation Steps
1. Clone the repository:
   ```bash
   git clone "https://github.com/AAShayon/sokrio_test.git](https://github.com/AAShayon/sokrio_test.git"
   cd sokrio-people-pulse
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (for Freezed, JsonSerializable, Drift):
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the application:
   ```bash
   flutter run
   ```

## 🌐 API Integration

The application fetches user data from the [ReqRes API](https://reqres.in/api/users) with the following endpoints:
- `GET /api/users?per_page=10&page={pageNumber}` - Paginated user list
- Pagination supports 10 users per page with configurable page numbers

## 🔄 Key Features Explained

### Cache and Offline-First Approach
- The app follows an offline-first strategy using Drift reactive streams
- When users open the app without internet, previously cached user data is immediately displayed
- Background synchronization attempts to refresh data when connectivity is restored
- Users can browse, search, and navigate through cached data during offline sessions

### Offline Capability
- Uses Drift SQLite database for local caching
- Automatically syncs data when connection is restored
- Continues to function during network outages
- When opening the app without internet, previously cached user data is displayed
- New data is fetched and cached when internet connection becomes available

### Pagination
- Implements infinite scroll loading
- Fetches users in batches (10 per request)
- Stops gracefully when no more data is available

### Search Functionality
- Real-time local filtering based on user names
- Maintains offline search capability
- Debounced search for optimal performance

### Error Handling
- Network error detection and user feedback
- Retry mechanisms for failed operations
- Graceful degradation for unavailable services

### Performance Optimizations
- Image caching for faster loading
- Lazy loading for infinite scroll
- Efficient state updates with Riverpod

## ✅ Problem Solutions Addressed

### Slow API Response
- Loading indicators during API calls
- Timeout mechanisms to prevent hanging requests
- Optimistic UI updates where appropriate

### No Internet Connection
- Clear offline state messaging
- Retry button functionality
- When the app starts with no internet, it displays cached user data from previous sessions
- Cached data is maintained using Drift SQLite database for seamless offline experience

### Empty API Response
- Friendly empty state messages
- Actionable guidance for users
- Proper visual feedback

### Search Edge Cases
- Special character handling
- Case-insensitive matching
- Space normalization in queries

### Navigation Issues
- Proper route management with GoRouter
- Memory leak prevention
- Back button handling

## 🧪 Testing Strategy

The project includes:
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for end-to-end functionality
- Mocking for external dependencies using Mockito

To run tests:
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test --target=test/widget_test.dart

# Run integration tests
flutter drive --target=integration_test/app_test.dart
```

- **APP Link Demo**: [Sokrio People Pulse](https://drive.google.com/file/d/1XxHjmirOe0pcq5S1mV-gfPC8qHhyzVE5/view?usp=sharing)
