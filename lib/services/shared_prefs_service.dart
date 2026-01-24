import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check if initialized
  static bool get isInitialized => _prefs != null;

  // ========== USER PREFERENCES ==========

  // User Authentication
  static Future<bool> setUserLoggedIn(bool value) async {
    return await _prefs?.setBool('isLoggedIn', value) ?? false;
  }

  static bool isUserLoggedIn() {
    return _prefs?.getBool('isLoggedIn') ?? false;
  }

  static Future<bool> setUserId(String userId) async {
    return await _prefs?.setString('userId', userId) ?? false;
  }

  static String getUserId() {
    return _prefs?.getString('userId') ?? '';
  }

  static Future<bool> setUserEmail(String email) async {
    return await _prefs?.setString('userEmail', email) ?? false;
  }

  static String getUserEmail() {
    return _prefs?.getString('userEmail') ?? '';
  }

  static Future<bool> setUserName(String name) async {
    return await _prefs?.setString('userName', name) ?? false;
  }

  static String getUserName() {
    return _prefs?.getString('userName') ?? '';
  }

  static Future<bool> setUserPhone(String phone) async {
    return await _prefs?.setString('userPhone', phone) ?? false;
  }

  static String getUserPhone() {
    return _prefs?.getString('userPhone') ?? '';
  }

  static Future<bool> setUserProfileImage(String imageUrl) async {
    return await _prefs?.setString('userProfileImage', imageUrl) ?? false;
  }

  static String getUserProfileImage() {
    return _prefs?.getString('userProfileImage') ?? '';
  }

  // User Role (Admin/User)
  static Future<bool> setUserRole(String role) async {
    return await _prefs?.setString('userRole', role) ?? false;
  }

  static String getUserRole() {
    return _prefs?.getString('userRole') ?? 'user';
  }

  static bool get isAdmin {
    return getUserRole() == 'admin';
  }

  // ========== APP SETTINGS ==========

  // Theme Mode (Light/Dark)
  static Future<bool> setThemeMode(String mode) async {
    return await _prefs?.setString('themeMode', mode) ?? false;
  }

  static String getThemeMode() {
    return _prefs?.getString('themeMode') ?? 'light';
  }

  static bool get isDarkMode {
    return getThemeMode() == 'dark';
  }

  // Language
  static Future<bool> setLanguage(String language) async {
    return await _prefs?.setString('language', language) ?? false;
  }

  static String getLanguage() {
    return _prefs?.getString('language') ?? 'en';
  }

  // Notification Settings
  static Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs?.setBool('notificationsEnabled', enabled) ?? false;
  }

  static bool get notificationsEnabled {
    return _prefs?.getBool('notificationsEnabled') ?? true;
  }

  static Future<bool> setEmailNotifications(bool enabled) async {
    return await _prefs?.setBool('emailNotifications', enabled) ?? false;
  }

  static bool get emailNotifications {
    return _prefs?.getBool('emailNotifications') ?? true;
  }

  // ========== APP DATA ==========

  // First Launch
  static Future<bool> setIsFirstLaunch(bool value) async {
    return await _prefs?.setBool('isFirstLaunch', value) ?? false;
  }

  static bool get isFirstLaunch {
    return _prefs?.getBool('isFirstLaunch') ?? true;
  }

  // Last App Version
  static Future<bool> setLastAppVersion(String version) async {
    return await _prefs?.setString('lastAppVersion', version) ?? false;
  }

  static String getLastAppVersion() {
    return _prefs?.getString('lastAppVersion') ?? '';
  }

  // Last Login Time
  static Future<bool> setLastLogin(DateTime dateTime) async {
    return await _prefs?.setString('lastLogin', dateTime.toIso8601String()) ?? false;
  }

  static DateTime? getLastLogin() {
    final dateString = _prefs?.getString('lastLogin');
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Search History
  static Future<bool> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return false;

    final List<String> searchHistory = getSearchHistory();

    // Remove if already exists
    searchHistory.remove(query.trim().toLowerCase());

    // Add to beginning
    searchHistory.insert(0, query.trim().toLowerCase());

    // Keep only last 10 searches
    final limitedList = searchHistory.take(10).toList();

    return await _prefs?.setStringList('searchHistory', limitedList) ?? false;
  }

  static List<String> getSearchHistory() {
    return _prefs?.getStringList('searchHistory') ?? [];
  }

  static Future<bool> clearSearchHistory() async {
    return await _prefs?.remove('searchHistory') ?? false;
  }

  // Favorites
  static Future<bool> addFavorite(String itemId, String itemType) async {
    final key = 'favorites_$itemType';
    final List<String> favorites = getFavorites(itemType);

    if (!favorites.contains(itemId)) {
      favorites.add(itemId);
      return await _prefs?.setStringList(key, favorites) ?? false;
    }

    return true;
  }

  static Future<bool> removeFavorite(String itemId, String itemType) async {
    final key = 'favorites_$itemType';
    final List<String> favorites = getFavorites(itemType);

    favorites.remove(itemId);
    return await _prefs?.setStringList(key, favorites) ?? false;
  }

  static List<String> getFavorites(String itemType) {
    final key = 'favorites_$itemType';
    return _prefs?.getStringList(key) ?? [];
  }

  static bool isFavorite(String itemId, String itemType) {
    return getFavorites(itemType).contains(itemId);
  }

  // ========== BOOKING PREFERENCES ==========

  // Preferred Payment Method
  static Future<bool> setPreferredPaymentMethod(String method) async {
    return await _prefs?.setString('preferredPaymentMethod', method) ?? false;
  }

  static String getPreferredPaymentMethod() {
    return _prefs?.getString('preferredPaymentMethod') ?? 'cash';
  }

  // Preferred Car Type
  static Future<bool> setPreferredCarType(String carType) async {
    return await _prefs?.setString('preferredCarType', carType) ?? false;
  }

  static String getPreferredCarType() {
    return _prefs?.getString('preferredCarType') ?? 'sedan';
  }

  // Preferred Hotel Star Rating
  static Future<bool> setPreferredHotelRating(int rating) async {
    return await _prefs?.setInt('preferredHotelRating', rating) ?? false;
  }

  static int getPreferredHotelRating() {
    return _prefs?.getInt('preferredHotelRating') ?? 3;
  }

  // ========== UTILITY METHODS ==========

  // Get all keys
  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }

  // Clear specific key
  static Future<bool> removeKey(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // Clear all user data (keep app settings)
  static Future<void> clearUserData() async {
    final keysToRemove = [
      'isLoggedIn',
      'userId',
      'userEmail',
      'userName',
      'userPhone',
      'userProfileImage',
      'userRole',
      'lastLogin',
      'searchHistory',
      'favorites_destinations',
      'favorites_hotels',
      'favorites_cars',
    ];

    for (final key in keysToRemove) {
      await _prefs?.remove(key);
    }
  }

  // Clear everything (full reset)
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // Get value by key with type
  static dynamic getValue(String key) {
    return _prefs?.get(key);
  }

  // Set value by key
  static Future<bool> setValue(String key, dynamic value) async {
    if (value is String) {
      return await _prefs?.setString(key, value) ?? false;
    } else if (value is int) {
      return await _prefs?.setInt(key, value) ?? false;
    } else if (value is double) {
      return await _prefs?.setDouble(key, value) ?? false;
    } else if (value is bool) {
      return await _prefs?.setBool(key, value) ?? false;
    } else if (value is List<String>) {
      return await _prefs?.setStringList(key, value) ?? false;
    }
    return false;
  }

  // Backup all data
  static Map<String, dynamic> backupAllData() {
    final Map<String, dynamic> backup = {};
    final keys = getAllKeys();

    for (final key in keys) {
      backup[key] = getValue(key);
    }

    return backup;
  }

  // Restore from backup
  static Future<void> restoreFromBackup(Map<String, dynamic> backup) async {
    for (final entry in backup.entries) {
      await setValue(entry.key, entry.value);
    }
  }
}