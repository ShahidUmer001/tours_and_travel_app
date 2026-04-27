# Tours & Travel App

A premium Flutter mobile application for tours and travel services in Pakistan. The app provides end-to-end booking flows for tours, hotels, and car rentals with Firebase-powered backend services.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup & Installation](#setup--installation)
- [Firebase Configuration](#firebase-configuration)
- [App Architecture](#app-architecture)
- [Screens Overview](#screens-overview)
- [Services Layer](#services-layer)
- [Data Models](#data-models)
- [User Flows](#user-flows)
- [Utilities & Helpers](#utilities--helpers)
- [Animations](#animations)
- [Screenshots](#screenshots)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)

---

## Features

- **Authentication** - Email/password, Google, Facebook, and Apple sign-in with Firebase Auth
- **Tour Booking** - Browse single destinations and multi-city tour packages with complete booking flow
- **Hotel Booking** - Search, select, and book hotels by city with date and guest selection
- **Car Rental** - City-to-city car booking with vehicle selection
- **Google Maps** - Interactive map with tourist destination markers across Pakistan
- **Profile Management** - User profile with photo upload via Firebase Storage
- **Booking History** - View past bookings filtered by Tours, Hotels, and Cars
- **User Listings** - Users can list their own hotels and cars for others to book
- **Premium UI/UX** - 20+ custom animations, shimmer loading, gradient themes, Material 3 design
- **Offline Fallback** - Hybrid auth system with SharedPreferences fallback when Firebase is unavailable

---

## Tech Stack

| Category | Technologies |
|----------|-------------|
| **Framework** | Flutter (Dart SDK >=3.0.0) |
| **Backend** | Firebase Core, Firebase Auth, Cloud Firestore, Firebase Storage |
| **Social Login** | Google Sign-In, Facebook Auth, Apple Sign-In |
| **Maps** | Google Maps Flutter, Geolocator, Permission Handler |
| **UI/Styling** | Google Fonts (Poppins), Material 3, Cached Network Image, Shimmer, Carousel Slider |
| **State** | setState + ChangeNotifier (LocalAuthService) |
| **Storage** | SharedPreferences (local), Firestore (cloud) |
| **Utilities** | intl, image_picker, url_launcher, webview_flutter, table_calendar |

---

## Project Structure

```
lib/
├── main.dart                              # App entry point & bootstrap
├── firebase_options.dart                  # Firebase project configuration
│
├── components/                            # Reusable UI components
│   ├── destination_card.dart              # Destination display card
│   └── tour_package_card.dart             # Tour package display card
│
├── models/                                # Data models
│   ├── destination_model.dart             # Destination entity
│   ├── hotel_model.dart                   # Hotel entity
│   ├── tour_model.dart                    # Tour package entity
│   ├── booking_model.dart                 # Tour booking entity
│   ├── hotel_booking_model.dart           # Hotel booking entity
│   ├── car_booking_model.dart             # Car booking entity
│   └── car_model.dart                     # Car/vehicle entity
│
├── screens/                               # App screens (20 total)
│   ├── login_screen.dart                  # Email + social login
│   ├── signup_screen.dart                 # User registration
│   ├── home_screen.dart                   # Main hub with bottom navigation
│   ├── destination_screen.dart            # Single destination details
│   ├── hotel_search_screen.dart           # Hotel search by city/dates
│   ├── hotel_selection_screen.dart        # Hotel picker with pricing
│   ├── multi_city_hotel_screen.dart       # Multi-city hotel selection
│   ├── car_booking_screen.dart            # Car rental booking
│   ├── transport_selection_screen.dart    # Transport option picker
│   ├── payment_screen.dart                # Payment processing UI
│   ├── booking_confirmation_screen.dart   # Post-payment confirmation
│   ├── booking_history_screen.dart        # Past bookings (tabs: All/Tours/Hotels/Cars)
│   ├── tour_booking_screen.dart           # Multi-city tour summary & booking
│   ├── profile_screen.dart                # User profile management
│   ├── map_screen.dart                    # Google Maps with tourist markers
│   ├── add_hotel_screen.dart              # Submit a hotel listing
│   ├── add_car_screen.dart                # Submit a car listing
│   ├── my_listings_screen.dart            # View user's own listings
│   └── firebase_data_initializer_screen.dart  # Seed demo data to Firestore
│
├── services/                              # Business logic & data access
│   ├── auth_service.dart                  # Firebase Auth wrapper
│   ├── local_auth_service.dart            # Hybrid auth (Firebase + local fallback)
│   ├── database_service.dart              # Firestore CRUD operations
│   ├── booking_service.dart               # Tour booking operations
│   ├── local_booking_store.dart           # In-memory booking session storage
│   ├── user_listings_service.dart         # User hotel/car listings (SharedPrefs)
│   ├── navigation_service.dart            # Global navigation helper
│   └── shared_prefs_service.dart          # SharedPreferences wrapper
│
├── utils/                                 # Utilities & configuration
│   ├── app_theme.dart                     # App theme (Poppins, Material 3, colors)
│   ├── constants.dart                     # Colors, gradients, spacing, text styles
│   ├── validators.dart                    # Form validators (email, phone, CNIC, etc.)
│   ├── extensions.dart                    # Dart extensions (String, DateTime, BuildContext)
│   ├── animations.dart                    # 20+ reusable animation widgets
│   └── sample_data.dart                   # Demo/sample data for development
│
└── widgets/                               # Generic reusable widgets
    ├── custom_button.dart                 # Styled button widget
    ├── cached_image.dart                  # Network image with caching
    └── local_image.dart                   # Local asset image display
```

---

## Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code with Flutter extension
- Firebase project (already configured)
- Google Maps API key (for map features)
- Android SDK (min SDK 21)

---

## Setup & Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/tours_and_travel_app.git
   cd tours_and_travel_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (see [Firebase Configuration](#firebase-configuration))

4. **Add Google Maps API key**

   In `android/app/src/main/AndroidManifest.xml`, ensure the API key is set:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## Firebase Configuration

The app uses Firebase for authentication, database, and storage. The Firebase project is already configured:

- **Project ID:** `tours-and-travel-app-6fd9d`
- **Platforms configured:** Android (fully configured), iOS/macOS (placeholders)

### Firestore Collections

| Collection | Purpose | Key Fields |
|-----------|---------|------------|
| `users` | User profiles | uid, email, fullName, createdAt, photoUrl, provider |
| `bookings` | Tour bookings | userId, destinationName, bookingDate, guests, totalPrice, status |
| `destinations` | Tour destinations | name, description, imageUrl, price, rating |
| `hotels` | Hotel listings | name, city, pricePerNight, amenities, imageUrl |
| `transport` | Transport options | type, pricePerKm, capacity |

### Firebase Storage

- `profile_images/` - User profile pictures uploaded via image picker

### To reconfigure Firebase

```bash
flutterfire configure
```

---

## App Architecture

### Bootstrap Flow (main.dart)

```
main()
  ├── WidgetsFlutterBinding.ensureInitialized()
  ├── Firebase.initializeApp()
  ├── LocalAuthService.instance.init()       # Load cached auth state
  ├── UserListingsService.instance.init()    # Load user listings from SharedPrefs
  └── runApp(MyApp())
        └── if isLoggedIn → HomeScreen
            else → LoginScreen
```

### State Management

- **LocalAuthService** - ChangeNotifier singleton for auth state, listened to via AnimatedBuilder in `MyApp`
- **Screen-level state** - `setState()` within StatefulWidget for UI state
- **Services** - Singleton pattern for shared services (auth, database, bookings, listings)

### Data Flow

```
UI (Screens) → Services → Firebase / SharedPreferences
                        → In-Memory Store (session bookings)
```

---

## Screens Overview

### Authentication (2 screens)
| Screen | Description |
|--------|-------------|
| `LoginScreen` | Email/password login with Google, Facebook, Apple social login buttons |
| `SignupScreen` | Registration with full name, email, phone, and password |

### Main Navigation (1 screen)
| Screen | Description |
|--------|-------------|
| `HomeScreen` | Main hub with bottom navigation (Explore, Bookings, Profile). Shows featured destinations, tour packages, and services grid |

### Tour Booking Flow (5 screens)
| Screen | Description |
|--------|-------------|
| `DestinationScreen` | Destination details with image gallery, highlights, and "Book Now" |
| `HotelSelectionScreen` | Choose hotel for selected destination |
| `TransportSelectionScreen` | Choose transport type |
| `PaymentScreen` | Enter payment details and confirm |
| `BookingConfirmationScreen` | Booking success with reference number |

### Multi-City Tour Flow (2 screens)
| Screen | Description |
|--------|-------------|
| `MultiCityHotelScreen` | Select hotels for each city in a multi-city tour |
| `TourBookingScreen` | Tour summary with itinerary and total price |

### Hotel & Car Booking (2 screens)
| Screen | Description |
|--------|-------------|
| `HotelSearchScreen` | Search hotels by city, dates, and number of guests |
| `CarBookingScreen` | Book city-to-city car rental with vehicle selection |

### Account & History (2 screens)
| Screen | Description |
|--------|-------------|
| `ProfileScreen` | View/edit profile, upload photo, sign out |
| `BookingHistoryScreen` | Tabbed view of all past bookings (All/Tours/Hotels/Cars) |

### User Listings (3 screens)
| Screen | Description |
|--------|-------------|
| `AddHotelScreen` | Form to list a new hotel |
| `AddCarScreen` | Form to list a new car |
| `MyListingsScreen` | View and manage user's own listings |

### Utility (2 screens)
| Screen | Description |
|--------|-------------|
| `MapScreen` | Google Maps with tourist destination markers across Pakistan |
| `FirebaseDataInitializerScreen` | Admin tool to seed demo data into Firestore |

---

## Services Layer

### AuthService (`services/auth_service.dart`)
Firebase Authentication wrapper providing sign-up, sign-in, sign-out, and user profile management.

### LocalAuthService (`services/local_auth_service.dart`)
Hybrid authentication service that combines Firebase Auth with SharedPreferences fallback. Acts as a ChangeNotifier for reactive auth state. Supports:
- Email/password authentication
- Google Sign-In
- Facebook Login
- Apple Sign-In
- Persistent session via SharedPreferences

### DatabaseService (`services/database_service.dart`)
Firestore CRUD operations for destinations, hotels, users, and bookings.

### BookingService (`services/booking_service.dart`)
Tour booking creation and retrieval with Firestore persistence.

### LocalBookingStore (`services/local_booking_store.dart`)
In-memory session storage for hotel and car bookings during the current app session.

### UserListingsService (`services/user_listings_service.dart`)
Manages user-submitted hotel and car listings stored in SharedPreferences. Supports add, remove, and retrieve operations.

### NavigationService (`services/navigation_service.dart`)
Global navigation key and helper methods for programmatic navigation.

### SharedPrefsService (`services/shared_prefs_service.dart`)
Centralized SharedPreferences wrapper for local key-value storage.

---

## Data Models

| Model | File | Storage | Description |
|-------|------|---------|-------------|
| `Destination` | `models/destination_model.dart` | Firestore | Tourist destination with name, description, images, price, rating |
| `Hotel` | `models/hotel_model.dart` | Firestore | Hotel with amenities, pricing, city, and images |
| `TourPackage` | `models/tour_model.dart` | Hardcoded | Multi-city tour with itinerary and included services |
| `Booking` | `models/booking_model.dart` | Firestore | Tour booking record with user, destination, dates, guests, total |
| `HotelBooking` | `models/hotel_booking_model.dart` | In-memory | Hotel booking with check-in/out, rooms, guests |
| `CarBooking` | `models/car_booking_model.dart` | In-memory | Car rental with pickup/dropoff cities, dates |
| `Car` | `models/car_model.dart` | Hardcoded | Vehicle with type, capacity, price/km, features |

**User Listing Models** (in `services/user_listings_service.dart`):
- `UserHotel` - User-submitted hotel listing
- `UserCar` - User-submitted car listing

---

## User Flows

### Flow 1: Single Destination Tour Booking
```
HomeScreen → DestinationScreen → HotelSelectionScreen → TransportSelectionScreen → PaymentScreen → BookingConfirmationScreen
```
Booking is saved to Firestore `bookings` collection.

### Flow 2: Multi-City Tour Booking
```
HomeScreen → MultiCityHotelScreen → TourBookingScreen → PaymentScreen → BookingConfirmationScreen
```
Booking is saved to Firestore `bookings` collection.

### Flow 3: Hotel Booking
```
HomeScreen → HotelSearchScreen → HotelSelectionScreen → PaymentScreen
```
Currently stored in-memory only (session-based).

### Flow 4: Car Rental Booking
```
HomeScreen → CarBookingScreen → PaymentScreen
```
Currently stored in-memory only (session-based).

### Flow 5: User Authentication
```
LoginScreen → (Email/Social Login) → HomeScreen
SignupScreen → (Registration) → HomeScreen
```
Auth state persisted via Firebase Auth + SharedPreferences.

### Flow 6: User Listings
```
HomeScreen → AddHotelScreen / AddCarScreen → MyListingsScreen
```
Listings stored in SharedPreferences.

---

## Utilities & Helpers

### Theme (`utils/app_theme.dart`)
- **Primary Color:** `#1565C0` (Material Blue)
- **Secondary Color:** `#00BFA5` (Teal)
- **Accent Color:** `#FF7043` (Deep Orange)
- **Font:** Poppins (via Google Fonts)
- **Design System:** Material 3
- **Card Radius:** 24px
- **Button Height:** 54px
- **Gradients:** 8+ presets (primary, accent, warm, gold, sky, sunset, aurora, forest, midnight)

### Constants (`utils/constants.dart`)
Centralized color definitions, gradient presets, spacing values, and text styles.

### Validators (`utils/validators.dart`)
Form field validators returning `String?` (null = valid):
- `validateEmail()` - RFC email pattern
- `validatePassword()` - 6+ chars, uppercase, number
- `validateName()` - 2+ chars, letters and spaces
- `validatePhone()` - Pakistan format (03XXXXXXXXX)
- `validateCNIC()` - Pakistan 13-digit format
- `validateCreditCard()` - 16-digit Luhn check
- `validateCVV()` - 3-4 digits
- `validateExpiryDate()` - MM/YY format

### Extensions (`utils/extensions.dart`)
Dart extension methods for cleaner code:

- **String** - `toTitleCase()`, `toFormattedPrice()`, `toFormattedPhone()`, `isValidEmail`, `initials`, `truncate()`
- **num** - `toFormattedPrice()`, `toFormattedRating()`, `toHoursMinutes()`
- **DateTime** - `toFormattedDate()`, `toFormattedDateTime()`, `isToday`, `isTomorrow`, `toRelativeTime()`
- **BuildContext** - `screenWidth`, `screenHeight`, `theme`, `showSnackBar()`, `navigateTo()`
- **List** - `addIfNotContains()`, `getSafe()`, `chunk()`
- **Map** - `getSafe()`, `toQueryString()`

---

## Animations

The app includes 20+ custom animation widgets (`utils/animations.dart`) for a premium user experience:

| Animation | Description |
|-----------|-------------|
| `StaggeredListItem` | Fade + slide animation for list items |
| `AnimatedFadeSlide` | Auto-playing fade and slide entrance |
| `ScaleOnTap` | Tap-to-scale interaction feedback |
| `ShimmerCardSkeleton` | Loading placeholder with shimmer effect |
| `PulseAnimation` | Gentle repeating pulse |
| `FloatingAnimation` | Hover/float effect |
| `GlowPulse` | Animated glow ring |
| `AnimatedCounter` | Count-up number animation |
| `AnimatedGradientBackground` | Cycling gradient background |
| `FloatingParticles` | Particle effects overlay |
| `BounceIn` / `RotateIn` | Entry animations |
| `ShimmerText` / `GradientText` | Animated text effects |
| `TypewriterText` | Character-by-character typing |
| `AnimatedBorderContainer` | Moving gradient border |
| `WaveLoader` | Wave dots loading indicator |
| `LiquidButton` | Gradient button with shine effect |
| `BlobDecoration` | Soft animated blob shape |
| `PressRipple` | Material ripple on press |
| `StaggeredEntry` | Grid stagger animation |
| `PageTransitions` | 5 custom page transitions (fadeSlide, fadeScale, heroFade, rotateScale, slideUp) |

---

## Screenshots

*Screenshots coming soon*

---

## Known Limitations

1. **Hotel/Car booking persistence** - Hotel and car bookings are session-based (in-memory) and not saved to Firestore
2. **Search functionality** - Search bar on HomeScreen is UI-only, not yet functional
3. **Provider not utilized** - `provider` package is declared but state management uses `setState`
4. **go_router not utilized** - `go_router` is declared but navigation uses `Navigator.push()`
5. **iOS/macOS Firebase** - Firebase config has placeholder values for iOS/macOS platforms
6. **Demo data** - Some screens use hardcoded sample data instead of Firestore data
7. **Tests** - Test suite has placeholder tests only

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is proprietary. All rights reserved.

---

**Built with Flutter & Firebase**
