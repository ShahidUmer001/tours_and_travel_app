import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbJp8fGb9e9VXdGdjGPdh85ccOGlen4XA',
    appId: '1:19348056231:android:92d7588cf14e15d7bdd382',
    messagingSenderId: '19348056231',
    projectId: 'tours-and-travel-app-6fd9d',
    databaseURL: 'https://tours-and-travel-app-6fd9d-default-rtdb.firebaseio.com',
    storageBucket: 'tours-and-travel-app-6fd9d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA6SdEXAMPLE_EXAMPLE_EXAMPLE',
    appId: '1:123456789012:ios:abcd1234example',
    messagingSenderId: '123456789012',
    projectId: 'tours-and-travel-app',
    storageBucket: 'tours-and-travel-app.appspot.com',
    iosBundleId: 'com.example.toursAndTravelApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA6SdEXAMPLE_EXAMPLE_EXAMPLE',
    appId: '1:123456789012:macos:abcd1234example',
    messagingSenderId: '123456789012',
    projectId: 'tours-and-travel-app',
    storageBucket: 'tours-and-travel-app.appspot.com',
    iosBundleId: 'com.example.toursAndTravelApp',
  );
}