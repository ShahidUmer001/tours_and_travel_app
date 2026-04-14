# Pakistan Tours & Travel App - Project Architecture

> Complete architecture documentation showing how every file, class, and module connects.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Directory Structure](#directory-structure)
3. [App Entry Point & Initialization](#app-entry-point--initialization)
4. [Authentication Flow](#authentication-flow)
5. [Models Layer](#models-layer)
6. [Services Layer](#services-layer)
7. [Screens Layer](#screens-layer)
8. [Widgets & Components](#widgets--components)
9. [Utilities Layer](#utilities-layer)
10. [Navigation & Routing](#navigation--routing)
11. [Data Flow Architecture](#data-flow-architecture)
12. [Firestore Database Schema](#firestore-database-schema)
13. [Dependencies & Packages](#dependencies--packages)
14. [State Management](#state-management)
15. [Known Issues & Notes](#known-issues--notes)

---

## 1. Project Overview

A Flutter-based travel and tourism app for **Pakistan**, offering:

- Tour destination browsing & booking (single + multi-city)
- Hotel search & reservation (40+ cities)
- City-to-city car rental
- Transport selection (bus, van, SUV, flight)
- Google Maps with 9 major tourist spots
- User authentication, profile management, booking history

**Tech Stack:** Flutter + Firebase (Auth, Firestore, Storage) + Google Maps

---

## 2. Directory Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase platform config
│
├── models/                            # Data models (7 files)
│   ├── destination_model.dart
│   ├── tour_model.dart
│   ├── hotel_model.dart
│   ├── booking_model.dart
│   ├── car_model.dart
│   ├── car_booking_model.dart
│   └── hotel_booking_model.dart
│
├── services/                          # Business logic & API layer (5 files)
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── booking_service.dart
│   ├── shared_prefs_service.dart
│   └── navigation_service.dart
│
├── screens/                           # UI screens (16 files)
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── destination_screen.dart
│   ├── hotel_selection_screen.dart
│   ├── hotel_search_screen.dart
│   ├── Car_Booking_Screen.dart
│   ├── transport_selection_screen.dart
│   ├── tour_booking_screen.dart
│   ├── multi_city_hotel_screen.dart
│   ├── map_screen.dart
│   ├── payment_screen.dart
│   ├── booking_confirmation_screen.dart
│   ├── booking_history_screen.dart
│   ├── firebase_data_initializer_screen.dart
│   └── auth_service.dart              # DUPLICATE - should be removed
│
├── widgets/                           # Reusable widgets (3 files)
│   ├── custom_button.dart
│   ├── cached_image.dart
│   └── local_image.dart
│
├── components/                        # Card components (2 files)
│   ├── destination_card.dart
│   └── tour_package_card.dart
│
└── utils/                             # Utilities & helpers (5 files)
    ├── app_theme.dart
    ├── constants.dart
    ├── validators.dart
    ├── extensions.dart
    └── sample_data.dart
```

---

## 3. App Entry Point & Initialization

### `main.dart`

```
main()
  └── Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
       └── runApp(MyApp)
            └── MaterialApp
                 ├── theme: AppTheme.lightTheme       ← from utils/app_theme.dart
                 ├── font: Poppins (Google Fonts)
                 └── home: StreamBuilder<User?>
                      ├── stream: FirebaseAuth.instance.authStateChanges()
                      ├── if authenticated → HomeScreen
                      └── if not authenticated → LoginScreen
```

**Key connections:**
- `main.dart` → `firebase_options.dart` (Firebase config)
- `main.dart` → `utils/app_theme.dart` (theme)
- `main.dart` → `screens/login_screen.dart` (unauthenticated)
- `main.dart` → `screens/home_screen.dart` (authenticated)

---

## 4. Authentication Flow

### Login Flow

```
LoginScreen
  │  uses: AuthService.signIn(email, password)
  │         └── FirebaseAuth.signInWithEmailAndPassword()
  │              └── returns UserCredential
  │  on success → Navigator.pushReplacement → HomeScreen
  │  on fail → SnackBar error message
  │
  └── "Don't have account?" → Navigator.push → SignupScreen
```

### Signup Flow

```
SignupScreen
  │  uses: AuthService.signUp(email, password, fullName, phone)
  │         ├── FirebaseAuth.createUserWithEmailAndPassword()
  │         └── Firestore.collection('users').doc(uid).set({
  │              uid, email, fullName, phone, createdAt
  │            })
  │  on success → Navigator.pushReplacement → HomeScreen
  │
  └── "Already have account?" → Navigator.push → LoginScreen
```

### Auth State Listener (in main.dart)

```
FirebaseAuth.authStateChanges() stream
  ├── User != null → HomeScreen
  └── User == null → LoginScreen
```

**Files involved:**
- `screens/login_screen.dart` → `services/auth_service.dart`
- `screens/signup_screen.dart` → `services/auth_service.dart`
- `services/auth_service.dart` → Firebase Auth + Firestore

---

## 5. Models Layer

All models live in `lib/models/` and define the data shapes used across the app.

### Model Relationships

```
Destination ──────────┐
  │                   │
  │ destinationId     │ destinations[] (list of names)
  ▼                   ▼
Hotel              TourPackage
  │                   │
  │ hotelId           │ tourId
  ▼                   ▼
HotelBooking       Booking (generic tour booking)
  │                   │
  └── userId ─────────┘──── links to Firebase Auth UID

Car ──────────────────┐
  │ carId             │
  ▼                   │
CarBooking ───────────┘
  │
  └── userId ──── links to Firebase Auth UID
```

### Model Details

| Model | File | Key Fields | Used By |
|-------|------|------------|---------|
| `Destination` | `destination_model.dart` | id, name, description, imageUrl, rating, location, price, duration, bestSeason, highlights | HomeScreen, DestinationScreen, DatabaseService |
| `TourPackage` | `tour_model.dart` | id, name, description, imageUrl, price, duration, destinations[], itinerary, category | HomeScreen, MultiCityHotelScreen |
| `Hotel` | `hotel_model.dart` | id, name, destinationId, rating, pricePerNight, amenities[], category | HotelSelectionScreen, HotelSearchScreen |
| `Booking` | `booking_model.dart` | id, userId, destinationName, destinationId, bookingDate, guests, totalPrice, status | BookingService, BookingHistoryScreen |
| `Car` | `car_model.dart` | id, name, type, pricePerKm, capacity, features[], transmission, fuelType | CarBookingScreen |
| `CarBooking` | `car_booking_model.dart` | id, userId, carId, carName, pickupCity, dropoffCity, totalAmount, status | BookingHistoryScreen |
| `HotelBooking` | `hotel_booking_model.dart` | id, userId, hotelId, hotelName, checkInDate, checkOutDate, rooms, totalAmount, status | BookingHistoryScreen |

---

## 6. Services Layer

Services are the bridge between screens (UI) and data sources (Firebase/Local Storage).

### Service Connection Map

```
┌─────────────────────────────────────────────────────────┐
│                      SCREENS                            │
│  (LoginScreen, HomeScreen, ProfileScreen, etc.)         │
└────────────┬───────────┬──────────┬────────────┬────────┘
             │           │          │            │
             ▼           ▼          ▼            ▼
        AuthService  DatabaseService  BookingService  SharedPrefsService
             │           │          │            │
             ▼           ▼          ▼            ▼
        Firebase     Firestore   Firestore   SharedPreferences
        Auth         (data)      (bookings)  (local storage)
```

### Service Details

#### `AuthService` (`services/auth_service.dart`)

| Method | What it does | Called by |
|--------|-------------|-----------|
| `signIn(email, password)` | Firebase Auth login | LoginScreen |
| `signUp(email, password, name, phone)` | Firebase Auth register + create Firestore user doc | SignupScreen |
| `getUserData()` | Fetch user doc from Firestore | ProfileScreen, HomeScreen |
| `signOut()` | Firebase sign out | ProfileScreen |
| `currentUser` (getter) | Get current FirebaseAuth user | Multiple screens |
| `userStream` (getter) | Auth state change stream | main.dart |

#### `DatabaseService` (`services/database_service.dart`)

| Method | What it does | Called by |
|--------|-------------|-----------|
| `getDestinations()` | Stream all destinations from Firestore | HomeScreen |
| `getDestination(id)` | Get single destination | DestinationScreen |
| `getHotels(destinationId)` | Stream hotels filtered by destination | HotelSelectionScreen |
| `getUserBookings(userId)` | Stream user's bookings | BookingHistoryScreen |
| `createBooking(booking)` | Save booking to Firestore | TourBookingScreen |
| `getDemoHotels()` | Return hardcoded demo hotel list | HotelSearchScreen |
| `getDemoDestinations()` | Return hardcoded demo destination list | HomeScreen |
| `getTransportOptions()` | Return transport types list | TransportSelectionScreen |
| `addSampleData()` | Populate Firestore with seed data | FirebaseDataInitializerScreen |
| `checkDataExists()` | Verify Firestore has data | FirebaseDataInitializerScreen |

#### `BookingService` (`services/booking_service.dart`)

| Method | What it does | Called by |
|--------|-------------|-----------|
| `getUserBookings(userId)` | Stream bookings with model conversion | BookingHistoryScreen |
| `createBooking(booking)` | Save booking doc to Firestore | PaymentScreen, TourBookingScreen |
| `updateBookingStatus(id, status)` | Update booking status field | BookingHistoryScreen |

#### `SharedPrefsService` (`services/shared_prefs_service.dart`)

| Category | Keys | Used by |
|----------|------|---------|
| User Data | isLoggedIn, userId, userEmail, userName, userPhone, userProfileImage, userRole | ProfileScreen, HomeScreen |
| Settings | themeMode, language, notificationsEnabled, emailNotifications | ProfileScreen |
| App Data | isFirstLaunch, lastAppVersion, lastLogin | main.dart |
| Preferences | searchHistory, favorites, preferredPaymentMethod, preferredCarType, preferredHotelRating | Various screens |

#### `NavigationService` (`services/navigation_service.dart`)

| Purpose | Used by |
|---------|---------|
| Provides helper methods for screen navigation | HomeScreen, other screens |

---

## 7. Screens Layer

### Screen Navigation Map

```
                        ┌──── main.dart ────┐
                        │                   │
                   (not logged in)     (logged in)
                        │                   │
                        ▼                   ▼
                   LoginScreen ◄──►  SignupScreen
                        │
                        ▼
              ┌──── HomeScreen ────────────────────────────────┐
              │    (Bottom Nav)                                │
              │                                                │
     ┌────────┴────────┐                              ProfileScreen
     │                 │                                │
  Explore Tab     Bookings Tab                    ┌─────┼──────┐
     │                 │                          │     │      │
     │          BookingHistoryScreen          Edit    Booking  Settings
     │              (tabs: All,              Profile  History
     │            Tours, Hotels, Cars)
     │
     ├─── Search → destinations filter
     │
     ├─── Services Grid:
     │    ├── Hotels → HotelSelectionScreen
     │    ├── Transport → TransportSelectionScreen
     │    ├── Map → MapScreen
     │    ├── City Car → CityToCityCarBookingScreen
     │    ├── All Hotels → AllPakistanHotelBookingScreen
     │    └── Photos → (gallery view)
     │
     ├─── Quick Cards:
     │    ├── City-to-City Car → CityToCityCarBookingScreen
     │    └── All Pakistan Hotels → AllPakistanHotelBookingScreen
     │
     ├─── Single Destination Tap:
     │    └── DestinationScreen
     │         └── Book Now → HotelSelectionScreen
     │              └── Select Hotel → PaymentScreen
     │                   └── Confirm → BookingConfirmationScreen
     │
     └─── Multi-City Tour Tap:
          └── MultiCityHotelScreen
               └── Book Tour → TourBookingScreen
                    └── Payment → PaymentScreen
                         └── Confirm → BookingConfirmationScreen
```

### Screen-to-Service Dependencies

| Screen | Services Used | Models Used |
|--------|--------------|-------------|
| `LoginScreen` | AuthService | - |
| `SignupScreen` | AuthService | - |
| `HomeScreen` | AuthService, DatabaseService | Destination, TourPackage |
| `ProfileScreen` | AuthService, SharedPrefsService, Firebase Storage | - |
| `DestinationScreen` | DatabaseService | Destination |
| `HotelSelectionScreen` | DatabaseService | Hotel |
| `AllPakistanHotelBookingScreen` | DatabaseService | Hotel |
| `CityToCityCarBookingScreen` | - | Car, CarBooking |
| `TransportSelectionScreen` | DatabaseService | - |
| `TourBookingScreen` | BookingService | TourPackage, Booking |
| `MultiCityHotelScreen` | - | TourPackage |
| `MapScreen` | - (uses Geolocator directly) | - |
| `PaymentScreen` | BookingService | Booking/HotelBooking/CarBooking |
| `BookingConfirmationScreen` | - | Booking |
| `BookingHistoryScreen` | BookingService | Booking, HotelBooking, CarBooking |
| `FirebaseDataInitializerScreen` | DatabaseService | - |

---

## 8. Widgets & Components

### Reusable Widgets (`lib/widgets/`)

#### `CustomButton` (`custom_button.dart`)

```
CustomButton
  ├── CustomButton(text, onPressed, ...)        # Default constructor
  ├── CustomButton.primary(text, onPressed)     # Blue filled button
  ├── CustomButton.success(text, onPressed)     # Green filled button
  ├── CustomButton.danger(text, onPressed)      # Red filled button
  ├── CustomButton.outlined(text, onPressed)    # Border-only button
  └── CustomButton.small(text, onPressed)       # Compact button
  
  Features: isLoading spinner, isDisabled state, icon support
  
  Used by: LoginScreen, SignupScreen, BookingScreens, PaymentScreen
```

#### `CachedImage` (`cached_image.dart`)

```
CachedImage
  ├── CachedImage(imageUrl, ...)                # Default constructor
  ├── CachedImage.circular(imageUrl, size)      # Round avatar
  ├── CachedImage.profile(imageUrl, size)       # Profile picture
  ├── CachedImage.banner(imageUrl, height)      # Full-width banner
  └── CachedImage.thumbnail(imageUrl, size)     # Small thumbnail
  
  Features: loading shimmer, error fallback, border radius, shadow
  
  Used by: DestinationScreen, HotelCards, ProfileScreen, HomeScreen
```

#### `LocalImage` (`local_image.dart`)

```
LocalImage
  └── For displaying local asset images
  
  Used by: Screens needing local asset display
```

### Card Components (`lib/components/`)

#### `DestinationCard` (`destination_card.dart`)

```
DestinationCard(destination)
  ├── Displays: image, name, location, rating, price
  ├── onTap → Navigator.push → DestinationScreen
  └── Used by: HomeScreen (destination list)
```

#### `TourPackageCard` (`tour_package_card.dart`)

```
TourPackageCard(tourPackage)
  ├── Displays: image, name, destinations, price, duration
  ├── onTap → Navigator.push → MultiCityHotelScreen
  └── Used by: HomeScreen (tour packages list)
```

---

## 9. Utilities Layer

### Connection Map

```
┌─────────────────────────────────────────────┐
│               ALL SCREENS                   │
└──┬──────────┬──────────┬──────────┬─────────┘
   │          │          │          │
   ▼          ▼          ▼          ▼
AppTheme   Constants  Validators  Extensions
   │          │          │          │
   │          │          │          ├── String extensions (toTitleCase, toFormattedPrice...)
   │          │          │          ├── DateTime extensions (toFormattedDate, isToday...)
   │          │          │          ├── BuildContext extensions (showSnackBar, navigateTo...)
   │          │          │          └── List/Map extensions
   │          │          │
   │          │          ├── validateEmail()
   │          │          ├── validatePassword()
   │          │          ├── validatePhone() (Pakistan format)
   │          │          ├── validateCNIC()
   │          │          └── validateCreditCard()
   │          │
   │          ├── primaryColor (0xFF1E88E5)
   │          ├── backgroundColor, textColor, etc.
   │          └── defaultRadius, defaultPadding, buttonHeight
   │
   └── lightTheme (Material 3)
        ├── AppBar theme
        ├── Card theme
        ├── Button themes
        ├── Input decoration theme
        ├── Text theme (Poppins)
        └── BottomNavigationBar theme
```

### Usage by Screen

| Utility | Used By |
|---------|---------|
| `AppTheme.lightTheme` | `main.dart` (MaterialApp theme) |
| `AppConstants.primaryColor` etc. | All screens and widgets |
| `Validators.validateEmail()` | LoginScreen, SignupScreen |
| `Validators.validatePassword()` | LoginScreen, SignupScreen |
| `Validators.validatePhone()` | SignupScreen, ProfileScreen |
| `Validators.validateCreditCard()` | PaymentScreen |
| `StringExtensions.toFormattedPrice()` | Destination, Hotel, Booking cards |
| `DateTimeExtensions.toFormattedDate()` | Booking screens, history |
| `BuildContextExtensions.showSnackBar()` | All screens (error/success messages) |

---

## 10. Navigation & Routing

The app uses **imperative navigation** (`Navigator.push/pushReplacement`) rather than the declared `go_router` package.

### Navigation Patterns

```dart
// Screen to screen (push)
Navigator.push(context, MaterialPageRoute(builder: (_) => TargetScreen()));

// Replace current screen (no back)
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TargetScreen()));

// Pop back
Navigator.pop(context);

// Via BuildContext extension
context.navigateTo(TargetScreen());
context.navigateReplacement(TargetScreen());
```

### Data Passing Between Screens

| From | To | Data Passed |
|------|----|-------------|
| HomeScreen | DestinationScreen | `Destination` object |
| HomeScreen | MultiCityHotelScreen | `TourPackage` object |
| HomeScreen | HotelSelectionScreen | `destinationId` |
| HomeScreen | CityToCityCarBookingScreen | - |
| HomeScreen | AllPakistanHotelBookingScreen | - |
| HomeScreen | MapScreen | - |
| HomeScreen | TransportSelectionScreen | - |
| DestinationScreen | HotelSelectionScreen | `destinationId`, `destinationName` |
| HotelSelectionScreen | PaymentScreen | `Hotel` object, booking details |
| PaymentScreen | BookingConfirmationScreen | `Booking` object |

---

## 11. Data Flow Architecture

### Complete Data Flow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                       PRESENTATION                           │
│                                                              │
│   Screens          Widgets           Components              │
│   ┌──────┐        ┌──────────┐      ┌────────────────┐      │
│   │Login │        │CustomBtn │      │DestinationCard │      │
│   │Home  │        │CachedImg │      │TourPackageCard │      │
│   │...   │        │LocalImg  │      └────────────────┘      │
│   └──┬───┘        └──────────┘                               │
│      │                                                       │
│      │  uses                                                 │
│      ▼                                                       │
│   ┌──────────────────────────────────────┐                   │
│   │           UTILS                      │                   │
│   │  AppTheme | Constants | Validators   │                   │
│   │  Extensions | SampleData             │                   │
│   └──────────────────────────────────────┘                   │
└──────────────────────┬───────────────────────────────────────┘
                       │ calls
                       ▼
┌──────────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC                             │
│                                                              │
│   ┌────────────┐  ┌───────────────┐  ┌──────────────┐       │
│   │AuthService │  │DatabaseService│  │BookingService │       │
│   └─────┬──────┘  └──────┬────────┘  └──────┬───────┘       │
│         │                │                   │               │
│   ┌─────┴────────────────┴───────────────────┘               │
│   │  SharedPrefsService  │  NavigationService                │
│   └──────────┬───────────┘                                   │
└──────────────┼───────────────────────────────────────────────┘
               │ reads/writes
               ▼
┌──────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│                                                              │
│   ┌────────────┐  ┌──────────┐  ┌────────────────────┐      │
│   │Firebase    │  │Firestore │  │SharedPreferences   │      │
│   │Auth       │  │(Cloud DB)│  │(Local Storage)     │      │
│   └────────────┘  └──────────┘  └────────────────────┘      │
│                                                              │
│   ┌────────────┐  ┌──────────────────────────────────┐      │
│   │Firebase    │  │ Models (Data Shapes)             │      │
│   │Storage    │  │ Destination, Hotel, Car, Booking  │      │
│   │(Images)   │  │ TourPackage, CarBooking,          │      │
│   └────────────┘  │ HotelBooking                     │      │
│                   └──────────────────────────────────┘      │
└──────────────────────────────────────────────────────────────┘
```

---

## 12. Firestore Database Schema

```
Firestore Root
│
├── users/                         # User profiles
│   └── {uid}/
│       ├── uid: string
│       ├── email: string
│       ├── fullName: string
│       ├── phone: string
│       ├── address: string (optional)
│       ├── profileImageUrl: string (optional)
│       ├── createdAt: timestamp
│       └── settings: map
│           ├── language: string
│           ├── nightMode: string
│           └── updatedAt: timestamp
│
├── destinations/                  # Travel destinations
│   └── {id}/
│       ├── name: string
│       ├── description: string
│       ├── imageUrl: string
│       ├── rating: double
│       ├── location: string
│       ├── price: double
│       ├── duration: string
│       ├── bestSeason: string
│       └── highlights: list<string>
│
├── hotels/                        # Hotels
│   └── {id}/
│       ├── name: string
│       ├── destinationId: string  ──── FK → destinations/{id}
│       ├── rating: double
│       ├── imageUrl: string
│       ├── location: string
│       ├── pricePerNight: double
│       ├── description: string
│       ├── amenities: list<string>
│       └── category: string
│
├── bookings/                      # Tour bookings
│   └── {id}/
│       ├── userId: string         ──── FK → users/{uid}
│       ├── destinationName: string
│       ├── destinationId: string  ──── FK → destinations/{id}
│       ├── bookingDate: timestamp
│       ├── guests: int
│       ├── totalPrice: double
│       └── status: string         (confirmed|pending|completed|cancelled)
│
├── carBookings/                   # Car rental bookings (inferred)
│   └── {id}/
│       ├── userId: string         ──── FK → users/{uid}
│       ├── carId: string
│       ├── carName: string
│       ├── pickupCity: string
│       ├── dropoffCity: string
│       ├── pickupDate: timestamp
│       ├── dropoffDate: timestamp
│       ├── totalAmount: double
│       ├── status: string
│       └── bookingDate: timestamp
│
└── hotelBookings/                 # Hotel bookings (inferred)
    └── {id}/
        ├── userId: string         ──── FK → users/{uid}
        ├── hotelId: string        ──── FK → hotels/{id}
        ├── hotelName: string
        ├── checkInDate: timestamp
        ├── checkOutDate: timestamp
        ├── guests: int
        ├── rooms: int
        ├── totalAmount: double
        ├── status: string
        └── bookingDate: timestamp
```

---

## 13. Dependencies & Packages

### Core

| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| `flutter` | SDK | Framework | Everywhere |
| `provider` | ^6.1.2 | State management | (Declared, minimal usage) |
| `cupertino_icons` | ^1.0.8 | iOS-style icons | Various screens |

### Firebase

| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| `firebase_core` | ^4.3.0 | Firebase init | main.dart |
| `firebase_auth` | ^6.1.3 | Authentication | AuthService |
| `cloud_firestore` | ^6.1.1 | Cloud database | DatabaseService, BookingService |
| `firebase_storage` | ^13.0.5 | File storage | ProfileScreen (image upload) |

### UI & Animations

| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| `google_fonts` | ^7.0.2 | Poppins font | AppTheme, main.dart |
| `cached_network_image` | ^3.4.1 | Image caching | CachedImage widget |
| `carousel_slider` | ^5.1.1 | Image carousels | HomeScreen, DestinationScreen |
| `flutter_rating_bar` | ^4.0.1 | Star ratings | Hotel/Destination cards |
| `shimmer` | ^3.0.0 | Loading effects | CachedImage |
| `flutter_spinkit` | ^5.2.0 | Loading spinners | Various screens |

### Maps & Location

| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| `google_maps_flutter` | ^2.14.0 | Google Maps | MapScreen |
| `geolocator` | ^14.0.2 | GPS location | MapScreen |
| `permission_handler` | ^12.0.1 | Runtime permissions | MapScreen, ProfileScreen |

### Utilities

| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| `http` | ^1.6.0 | HTTP requests | (Available for API calls) |
| `image_picker` | ^1.0.7 | Photo selection | ProfileScreen |
| `shared_preferences` | ^2.2.2 | Local storage | SharedPrefsService |
| `url_launcher` | ^6.2.2 | Open URLs | ProfileScreen |
| `intl` | ^0.19.0 | Date formatting | Extensions, booking screens |
| `webview_flutter` | ^4.4.2 | Web content | (Available for web views) |
| `table_calendar` | ^3.0.11 | Calendar UI | (Available for date picking) |
| `go_router` | ^14.0.1 | Declarative routing | (Declared but not actively used) |

---

## 14. State Management

The app uses a **mixed approach** to state management:

| Approach | Where Used | Purpose |
|----------|-----------|---------|
| **Firebase Auth StreamBuilder** | `main.dart` | Real-time auth state (logged in/out) |
| **Firestore StreamBuilder** | HomeScreen, BookingHistoryScreen | Real-time data from Firestore |
| **StatefulWidget + setState** | All screens | Local UI state (loading, selections, form fields) |
| **SharedPreferences** | ProfileScreen, Settings | Persistent local preferences |
| **Provider** | Declared in pubspec | Available but not heavily used yet |

---

## 15. Known Issues & Notes

### Issues to Address

1. **Duplicate file:** `lib/screens/auth_service.dart` is a copy of `lib/services/auth_service.dart` - should be removed
2. **Unused package:** `go_router` is declared but navigation uses imperative `Navigator.push` instead
3. **Unused package:** `provider` is declared but StatefulWidget + setState is used for most state
4. **File naming:** `Car_Booking_Screen.dart` uses PascalCase instead of snake_case convention
5. **Demo data dependency:** Several screens rely on hardcoded demo data instead of Firestore
6. **Incomplete screens:** `payment_screen.dart` and `booking_confirmation_screen.dart` may need completion

### Architecture Notes

- **No dedicated state management** - screens manage their own state via StatefulWidget
- **Services are not singletons** - new instances may be created per screen
- **No error boundary** - app-level error handling could be improved
- **No offline support** - Firestore offline persistence is available but not configured
- **No deep linking** - go_router could enable this if wired up
- **Firebase Storage** used only for profile images currently
