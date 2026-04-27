import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import '../main.dart' show firebaseInitialized;

/// Hybrid authentication service.
/// - When Firebase is initialized (Android with google-services.json):
///   Uses Firebase Auth + Firestore for real backend auth.
/// - When Firebase is not initialized (e.g., web without config):
///   Falls back to local SharedPreferences-based auth.
class LocalAuthService extends ChangeNotifier {
  LocalAuthService._();
  static final LocalAuthService instance = LocalAuthService._();

  static const _kUsersKey = 'local_users_v1'; // Format: email|password|fullName;...
  static const _kCurrentEmailKey = 'local_current_email_v1';

  String? _currentEmail;
  String? _currentFullName;

  String? get currentEmail => _currentEmail;
  String? get currentFullName => _currentFullName;
  bool get isLoggedIn => _currentEmail != null;

  Future<void> init() async {
    // If Firebase is available, hydrate from current Firebase user.
    if (firebaseInitialized) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentEmail = user.email;
        _currentFullName = user.displayName;
        notifyListeners();
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _currentEmail = prefs.getString(_kCurrentEmailKey);
    if (_currentEmail != null) {
      final users = _parseUsers(prefs.getString(_kUsersKey));
      _currentFullName = users[_currentEmail]?['fullName'];
    }
    notifyListeners();
  }

  Map<String, Map<String, String>> _parseUsers(String? raw) {
    final result = <String, Map<String, String>>{};
    if (raw == null || raw.isEmpty) return result;
    for (final entry in raw.split(';')) {
      if (entry.isEmpty) continue;
      final parts = entry.split('|');
      if (parts.length < 3) continue;
      result[parts[0]] = {
        'password': parts[1],
        'fullName': parts[2],
      };
    }
    return result;
  }

  String _serializeUsers(Map<String, Map<String, String>> users) {
    return users.entries
        .map((e) => '${e.key}|${e.value['password']}|${e.value['fullName']}')
        .join(';');
  }

  /// Returns null on success, or error message on failure.
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      return 'Please fill all fields';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Try Firebase first if available
    if (firebaseInitialized) {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await credential.user?.updateDisplayName(fullName.trim());
        // Store user profile in Firestore
        if (credential.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .set({
            'uid': credential.user!.uid,
            'email': email.trim(),
            'fullName': fullName.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        // Sign out so user goes through login flow explicitly
        await FirebaseAuth.instance.signOut();
        return null;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return 'Account already exists. Please login instead.';
        }
        if (e.code == 'weak-password') {
          return 'Password is too weak';
        }
        if (e.code == 'invalid-email') {
          return 'Invalid email address';
        }
        return e.message ?? 'Sign up failed';
      } catch (e) {
        return 'Sign up failed: $e';
      }
    }

    // Fallback to local storage
    final prefs = await SharedPreferences.getInstance();
    final users = _parseUsers(prefs.getString(_kUsersKey));
    final normalizedEmail = email.trim().toLowerCase();
    if (users.containsKey(normalizedEmail)) {
      return 'Account already exists. Please login instead.';
    }
    users[normalizedEmail] = {
      'password': password,
      'fullName': fullName.trim(),
    };
    await prefs.setString(_kUsersKey, _serializeUsers(users));
    return null;
  }

  /// Returns null on success, or error message on failure.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill all fields';
    }

    // Try Firebase first if available
    if (firebaseInitialized) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        _currentEmail = credential.user?.email;
        _currentFullName = credential.user?.displayName;
        notifyListeners();
        return null;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          return 'No account found. Please sign up first.';
        }
        if (e.code == 'wrong-password') {
          return 'Incorrect password';
        }
        if (e.code == 'invalid-email') {
          return 'Invalid email address';
        }
        return e.message ?? 'Sign in failed';
      } catch (e) {
        return 'Sign in failed: $e';
      }
    }

    // Fallback to local storage
    final prefs = await SharedPreferences.getInstance();
    final users = _parseUsers(prefs.getString(_kUsersKey));
    final normalizedEmail = email.trim().toLowerCase();
    final user = users[normalizedEmail];
    if (user == null) {
      return 'No account found. Please sign up first.';
    }
    if (user['password'] != password) {
      return 'Incorrect password';
    }
    _currentEmail = normalizedEmail;
    _currentFullName = user['fullName'];
    await prefs.setString(_kCurrentEmailKey, normalizedEmail);
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    if (firebaseInitialized) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      try {
        await FacebookAuth.instance.logOut();
      } catch (_) {}
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentEmailKey);
    _currentEmail = null;
    _currentFullName = null;
    notifyListeners();
  }

  // ============================================================
  // GOOGLE SIGN-IN
  // ============================================================
  Future<String?> signInWithGoogle() async {
    if (!firebaseInitialized) {
      return 'Firebase is not available. Google Sign-In requires Firebase.';
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return 'Google Sign-In was cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        // Save/update user profile in Firestore
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email ?? '',
            'fullName': user.displayName ?? '',
            'photoUrl': user.photoURL ?? '',
            'provider': 'google',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        _currentEmail = user.email;
        _currentFullName = user.displayName;
        notifyListeners();
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Google Sign-In failed';
    } catch (e) {
      return 'Google Sign-In failed: $e';
    }
  }

  // ============================================================
  // FACEBOOK SIGN-IN
  // ============================================================
  Future<String?> signInWithFacebook() async {
    if (!firebaseInitialized) {
      return 'Firebase is not available. Facebook Sign-In requires Firebase.';
    }

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) {
        return 'Facebook Sign-In was cancelled';
      }

      if (result.status != LoginStatus.success || result.accessToken == null) {
        return 'Facebook Sign-In failed: ${result.message}';
      }

      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        // Get Facebook user data
        final userData = await FacebookAuth.instance.getUserData(
          fields: 'name,email,picture.width(200)',
        );

        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email ?? userData['email'] ?? '',
            'fullName': user.displayName ?? userData['name'] ?? '',
            'photoUrl': user.photoURL ?? '',
            'provider': 'facebook',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        _currentEmail = user.email;
        _currentFullName = user.displayName ?? userData['name'];
        notifyListeners();
      }

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Facebook Sign-In failed';
    } catch (e) {
      return 'Facebook Sign-In failed: $e';
    }
  }

  // ============================================================
  // APPLE SIGN-IN
  // ============================================================
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> signInWithApple() async {
    if (!firebaseInitialized) {
      return 'Firebase is not available. Apple Sign-In requires Firebase.';
    }

    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final user = userCredential.user;
      if (user != null) {
        // Apple only provides name on first sign-in
        String fullName = '';
        if (appleCredential.givenName != null) {
          fullName =
              '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                  .trim();
        }

        if (fullName.isNotEmpty) {
          await user.updateDisplayName(fullName);
        }

        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email ?? appleCredential.email ?? '',
            'fullName': fullName.isNotEmpty
                ? fullName
                : (user.displayName ?? ''),
            'provider': 'apple',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        _currentEmail = user.email ?? appleCredential.email;
        _currentFullName = fullName.isNotEmpty
            ? fullName
            : user.displayName;
        notifyListeners();
      }

      return null; // success
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return 'Apple Sign-In was cancelled';
      }
      return 'Apple Sign-In failed: ${e.message}';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Apple Sign-In failed';
    } catch (e) {
      return 'Apple Sign-In failed: $e';
    }
  }
}
