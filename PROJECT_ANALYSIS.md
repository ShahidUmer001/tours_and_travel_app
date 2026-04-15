# Tours And Travel App - Project Analysis

Last reviewed: 2026-04-14

## 1. What This Project Is

This is a Flutter mobile app for tours and travel in Pakistan. The app currently combines:

- Firebase authentication
- Firestore user and booking storage
- Firebase Storage for profile images
- Google Maps and device location
- Multiple booking flows for tours, hotels, and city-to-city cars
- A large amount of hardcoded demo/sample data mixed with some real Firebase-backed screens

At a high level, the project already has a lot of UI and feature coverage, but the codebase is in a mixed state:

- Some features are connected to Firebase
- Some features are still demo-only
- Some utilities/services exist but are not fully wired into the app
- There are a few structural inconsistencies we should clean up before scaling further

## 2. Tech Stack

Main stack from `pubspec.yaml` and current source usage:

- Flutter
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Firebase Storage
- Google Maps Flutter
- Geolocator
- Image Picker
- Shared Preferences
- URL Launcher
- Cached Network Image

Dependencies declared but not clearly used in the current `lib/` source scan:

- `provider`
- `google_fonts`
- `carousel_slider`
- `flutter_rating_bar`
- `shimmer`
- `flutter_spinkit`
- `go_router`
- `http`
- `webview_flutter`
- `table_calendar`

## 3. Current App Boot Flow

Entry point: `lib/main.dart`

How startup works:

1. Flutter bindings are initialized.
2. Firebase is initialized with `firebase_options.dart`.
3. `MaterialApp` is launched.
4. The app uses `FirebaseAuth.instance.authStateChanges()` to decide the first screen:
   - Logged in -> `HomeScreen`
   - Logged out -> `LoginScreen`

Important notes:

- `MaterialApp` does not currently define named routes.
- Theme is created inline in `main.dart`.
- `AppTheme` exists in `lib/utils/app_theme.dart` but is not used.
- `NavigationService` exists in `lib/services/navigation_service.dart` but is not wired into the app.

## 4. Project Structure

High-level structure:

```text
lib/
  main.dart
  firebase_options.dart
  components/
  models/
  screens/
  services/
  utils/
  widgets/
```

What each folder currently does:

- `components/`
  Reusable destination and tour package card widgets.

- `models/`
  Data models for destinations, hotels, tours, bookings, cars, hotel bookings, and car bookings.

- `screens/`
  Most of the app logic lives here. This is the main feature layer.

- `services/`
  Firebase auth, booking, Firestore helpers, navigation helper, and shared prefs helper.

- `utils/`
  Theme/constants/extensions/sample seed data/validators.

- `widgets/`
  Reusable UI building blocks such as cached image and custom button.

## 5. Main User Flows

### A. Authentication

Files:

- `lib/screens/login_screen.dart`
- `lib/screens/signup_screen.dart`
- `lib/services/auth_service.dart`

Behavior:

- Login uses Firebase Auth email/password sign-in.
- Signup creates a Firebase Auth user and also creates a Firestore document under `users/{uid}`.
- After login/signup, the user is navigated directly to `HomeScreen`.

Stored Firestore user fields from signup:

- `uid`
- `email`
- `fullName`
- `phone`
- `createdAt`

Observation:

- Signup screen collects phone number, but `AuthService.signUp()` currently stores an empty phone string instead of the entered value.

### B. Home / Explore

Main file:

- `lib/screens/home_screen.dart`

What it currently does:

- Shows greeting based on Firebase user state
- Reads user profile info from Firestore `users/{uid}`
- Has a bottom navigation with:
  - Explore
  - Bookings
- Explore tab contains:
  - Search bar
  - Services grid
  - Quick access shortcuts
  - Single-destination tour cards
  - Multi-city tour package cards

Important detail:

- The destination and tour content on the home screen is mostly hardcoded in the screen itself.
- The search bar appears to be UI-only right now; it does not actually filter the destination/tour lists.

### C. Single Destination Tour Flow

Primary path:

`HomeScreen -> DestinationScreen -> HotelSelectionScreen -> TransportSelectionScreen -> PaymentScreen`

Files involved:

- `lib/screens/destination_screen.dart`
- `lib/screens/hotel_selection_screen.dart`
- `lib/screens/transport_selection_screen.dart`
- `lib/screens/payment_screen.dart`

How it works:

- The user taps a single destination from the home screen.
- `DestinationScreen` shows details, highlights, gallery, and a "Book Now" button.
- `HotelSelectionScreen` loads hotels from a local hardcoded list filtered by `destinationId`.
- `TransportSelectionScreen` lets the user choose a transport option from another hardcoded list.
- `PaymentScreen` handles payment UI and shows a success screen.

Important limitation:

- This flow currently simulates payment success but does not appear to save a full single-destination booking to Firestore.

### D. Multi-City Tour Flow

Primary path:

`HomeScreen -> MultiCityHotelScreen -> TourBookingScreen`

Files involved:

- `lib/screens/multi_city_hotel_screen.dart`
- `lib/screens/tour_booking_screen.dart`
- `lib/services/booking_service.dart`

How it works:

- The user taps a multi-city tour package from the home screen.
- `MultiCityHotelScreen` asks the user to select hotels for each destination in the itinerary.
- The screen calculates a combined price using the tour package plus hotel totals.
- `TourBookingScreen` shows booking summary, user info, and payment method selection.
- On confirm, a simplified `Booking` object is created and saved to Firestore through `BookingService`.

Important limitation:

- The booking stored in Firestore is simplified and does not preserve all hotel/transport/payment detail.
- The current saved `Booking` model is focused mainly on tour-style bookings.

### E. Hotel Booking Flow

Primary path:

`HomeScreen -> AllPakistanHotelBookingScreen -> PaymentScreen`

Files involved:

- `lib/screens/Hotel_Search_Screen.dart`
- `lib/screens/payment_screen.dart`

How it works:

- User selects city, dates, guest count, and rooms.
- Hotels are generated from hardcoded sample data for the selected city.
- User taps "Book Now" and booking details are passed into `PaymentScreen` with `bookingType: 'hotel'`.

Important limitation:

- This flow currently looks like a front-end booking experience only.
- It does not appear to persist hotel bookings to Firestore.

### F. City-to-City Car Booking Flow

Primary path:

`HomeScreen -> CityToCityCarBookingScreen -> PaymentScreen`

Files involved:

- `lib/screens/Car_Booking_Screen.dart`
- `lib/screens/payment_screen.dart`

How it works:

- User selects pickup city, dropoff city, date, time, days, and a car.
- Total amount is calculated from estimated distance and car price per km.
- Data is passed into `PaymentScreen` with `bookingType: 'car'`.

Important limitation:

- This flow also appears to stop at payment/success UI.
- It does not appear to persist car bookings to Firestore.

### G. Booking History

Main file:

- `lib/screens/booking_history_screen.dart`

How it works:

- The screen has tabs for:
  - All
  - Tours
  - Hotels
  - Cars
- Tour bookings are loaded from Firestore using `BookingService.getUserBookings(userId)`.
- Hotel and car bookings are currently sample in-memory lists inside the screen.

Important implication:

- The bookings tab is only partially connected to real backend data.
- Tour bookings are real.
- Hotel/car bookings shown in history are currently fake/demo data.

### H. Profile

Main file:

- `lib/screens/profile_screen.dart`

What it currently supports:

- Load current user info from Firestore
- Edit profile details
- Upload a profile image to Firebase Storage
- Save user settings
- Open external URLs with `url_launcher`
- Delete account / sign out flows

Storage used here:

- Firestore `users/{uid}`
- Firebase Storage `profile_images/...`
- SharedPreferences for local settings

Observation:

- `ProfileScreen` talks directly to `SharedPreferences`, not through `SharedPrefsService`.

### I. Map

Main file:

- `lib/screens/map_screen.dart`

What it does:

- Requests location permission through `geolocator`
- Gets current location
- Displays Google Map
- Adds hardcoded Pakistan tourist spot markers
- Shows a bottom sheet with location details on tap

## 6. Data Layer

### Models Present

Files in `lib/models/`:

- `Destination`
- `Hotel`
- `TourPackage`
- `Booking`
- `HotelBooking`
- `Car`
- `CarBooking`

Current pattern:

- `Booking` is the main Firestore-backed booking model for tours.
- `HotelBooking` and `CarBooking` exist as richer models, but they are not consistently persisted from the current booking flows.

### Firestore Collections Observed

Based on the current code, these collections are expected:

- `users`
- `bookings`
- `destinations`
- `hotels`
- `transport`

How they are used today:

- `users`
  Actively used for auth-related profile data and profile updates.

- `bookings`
  Used mainly by `TourBookingScreen` and `BookingService`.

- `destinations`, `hotels`, `transport`
  Supported by `DatabaseService` and sample/seed helpers, but much of the UI still uses inline hardcoded lists instead of these collections.

## 7. Services Layer

### `AuthService`

Purpose:

- Sign in
- Sign up
- Sign out
- Expose auth state stream
- Fetch user profile document

Status:

- Actively used by login/signup/home/profile.

### `BookingService`

Purpose:

- Get user bookings
- Create booking
- Update booking status

Status:

- Actively used for tour bookings/history.

### `DatabaseService`

Purpose:

- Stream destinations/hotels
- Create bookings
- Provide demo destinations/hotels/transport
- Seed sample Firestore data

Status:

- Useful helper service, but much of the UI bypasses it and keeps hardcoded data inside screens.

### `SharedPrefsService`

Purpose:

- Centralized wrapper around `SharedPreferences`

Status:

- Present but not fully integrated.
- `main.dart` does not initialize it.
- `ProfileScreen` uses `SharedPreferences` directly instead.

### `NavigationService`

Purpose:

- Global navigator helper for route navigation, dialogs, sheets, and snackbars

Status:

- Not connected to the current `MaterialApp`.

## 8. UI / State Management Reality

Current UI architecture is mostly:

- Large stateful screens
- Local `setState`
- Direct navigation with `Navigator.push(...)`
- Firestore reads directly inside screens

This means:

- The app is fast to prototype in
- But logic is spread across many big screen files
- State is not centralized
- Reuse is limited
- Testing is harder than it needs to be

Some of the largest files right now:

- `home_screen.dart`
- `booking_history_screen.dart`
- `profile_screen.dart`
- `hotel_selection_screen.dart`
- `payment_screen.dart`
- `tour_booking_screen.dart`

These are likely to be our highest-value cleanup targets later.

## 9. Assets and Media

Current assets on disk are minimal:

- `assets/icons/placeholder.png`
- `assets/images/destinations/Hunza_1.jpg`

Most screen visuals currently rely on network images.

Implication:

- The UI depends heavily on remote image URLs.
- Broken URLs or slow networks will directly affect the app experience.

## 10. Current Technical Gaps and Risks

These are the biggest issues I noticed while reading the project:

### 1. Mixed source of truth

The app mixes:

- Firestore data
- Service-level demo data
- Screen-level hardcoded data

This makes it difficult to know which layer is the real source of truth.

### 2. Booking system is inconsistent across flows

- Multi-city tour flow saves to Firestore
- Single-destination, hotel, and car flows mostly stop at payment/success UI
- Booking history only shows real Firestore data for tours

### 3. Unused or partially used architecture pieces

- `AppTheme` exists but is not used
- `NavigationService` exists but is not used
- `SharedPrefsService` exists but is not properly integrated
- `provider` and `go_router` are declared but not wired in

### 4. Duplicate / confusing files or classes

Observed examples:

- `lib/screens/auth_service.dart` is just a placeholder and conflicts by name with the real service file
- `BookingSuccessScreen` exists in more than one screen file
- `lib/module-info.java` inside the Flutter `lib/` folder looks accidental/out of place

### 5. File naming inconsistency across imports

There is a case/style mismatch between some imports and actual file names, for example:

- import uses `car_booking_screen.dart` but the file is `Car_Booking_Screen.dart`
- import uses `hotel_search_screen.dart` but the file is `Hotel_Search_Screen.dart`

This may work on Windows but can break on case-sensitive environments.

### 6. Navigation mismatch

`PaymentScreen` success flow uses:

- `Navigator.pushNamedAndRemoveUntil(context, '/home', ...)`

But `MaterialApp` currently does not define a `/home` named route.

### 7. Search and filtering are incomplete

The home search bar does not currently apply any real filtering.

### 8. Seed/sample data is duplicated in multiple places

Sample data logic currently exists in multiple areas:

- `DatabaseService`
- `SampleData`
- `FirebaseDataInitializerScreen`
- Some screens directly

This can drift out of sync quickly.

### 9. Tests are not aligned with the real app

`test/widget_test.dart` is still the default Flutter counter test and does not match this application.

### 10. I did not finish a live analyzer pass

I started a `flutter analyze` run, but it was interrupted before completion, so this document is based on source inspection rather than a completed analyzer result.

## 11. Best Mental Model For This Codebase

Right now, the simplest way to think about this project is:

- It is a feature-rich Flutter travel app prototype with real Firebase auth/profile support
- Tour booking has partial backend integration
- Hotel/car booking are more UI-complete than backend-complete
- The app has enough screens to feel like a product, but it still needs consolidation before it becomes a clean, maintainable system

## 12. Suggested Next Work Order

When we continue, this is the order I would recommend:

1. Decide the real data strategy:
   - fully Firebase-backed
   - or demo-first with a later backend hookup

2. Unify booking persistence:
   - make tour, hotel, and car bookings all save in a consistent way

3. Clean the structure:
   - remove placeholder/duplicate files
   - normalize file naming
   - choose whether to use `setState`, `provider`, or another state pattern consistently

4. Consolidate sample data:
   - keep it in one place instead of scattering it across screens and services

5. Fix navigation/theme plumbing:
   - either use named routes/router properly or keep everything fully manual
   - wire in `AppTheme` if we want centralized styling

6. Replace placeholder tests and run analyzer/test cleanly

## 13. Best Files To Start With Later

If we begin refactoring or feature work, these are the most strategic files:

- `lib/main.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/booking_history_screen.dart`
- `lib/screens/payment_screen.dart`
- `lib/screens/tour_booking_screen.dart`
- `lib/services/booking_service.dart`
- `lib/services/database_service.dart`

## 14. Short Summary

This app already has a solid visual and feature foundation. The main thing it needs next is not more screens, but consistency:

- one clear data source
- one consistent booking pipeline
- one cleaner navigation/state structure

Once those pieces are aligned, the project will become much easier to extend safely.
