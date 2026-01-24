import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String Extensions
extension StringExtensions on String {
  /// Capitalize first letter of each word
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  /// Format price with commas (e.g., 10000 -> "10,000")
  String toFormattedPrice() {
    try {
      final number = int.tryParse(this) ?? 0;
      final formatter = NumberFormat('#,##0', 'en_PK');
      return 'Rs. ${formatter.format(number)}';
    } catch (e) {
      return 'Rs. $this';
    }
  }

  /// Format phone number (e.g., 03001234567 -> "0300 1234567")
  String toFormattedPhone() {
    if (length != 11) return this;
    return '${substring(0, 4)} ${substring(4, 7)}${substring(7)}';
  }

  /// Format CNIC (e.g., 1234512345671 -> "12345-1234567-1")
  String toFormattedCNIC() {
    if (length != 13) return this;
    return '${substring(0, 5)}-${substring(5, 12)}-${substring(12)}';
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );
    return emailRegex.hasMatch(trim());
  }

  /// Check if string is a valid Pakistan phone number
  bool get isValidPakistanPhone {
    final cleanedPhone = replaceAll(RegExp(r'[\s\-+]'), '');
    final phoneRegex = RegExp(r'^03[0-9]{9}$');
    return phoneRegex.hasMatch(cleanedPhone);
  }

  /// Get initials from name (e.g., "John Doe" -> "JD")
  String get initials {
    if (isEmpty) return '';
    final parts = split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

/// Number Extensions
extension IntExtensions on int {
  /// Format price with commas
  String toFormattedPrice() {
    final formatter = NumberFormat('#,##0', 'en_PK');
    return 'Rs. ${formatter.format(this)}';
  }

  /// Format rating (e.g., 4.5 -> "4.5")
  String toFormattedRating() {
    return toStringAsFixed(1);
  }

  /// Convert minutes to hours and minutes string
  String toHoursMinutes() {
    final hours = this ~/ 60;
    final minutes = this % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

extension DoubleExtensions on double {
  /// Format price with commas
  String toFormattedPrice() {
    final formatter = NumberFormat('#,##0.00', 'en_PK');
    return 'Rs. ${formatter.format(this)}';
  }

  /// Format rating (e.g., 4.5 -> "4.5")
  String toFormattedRating() {
    return toStringAsFixed(1);
  }
}

/// DateTime Extensions
extension DateTimeExtensions on DateTime {
  /// Format date as "dd MMM yyyy" (e.g., "15 Jan 2024")
  String toFormattedDate() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  /// Format date and time as "dd MMM yyyy, hh:mm a" (e.g., "15 Jan 2024, 02:30 PM")
  String toFormattedDateTime() {
    return DateFormat('dd MMM yyyy, hh:mm a').format(this);
  }

  /// Format time as "hh:mm a" (e.g., "02:30 PM")
  String toFormattedTime() {
    return DateFormat('hh:mm a').format(this);
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Get relative time (e.g., "2 hours ago", "Tomorrow", "Yesterday")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = this.difference(now);

    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isYesterday) return 'Yesterday';

    if (difference.inDays.abs() < 30) {
      return '${difference.inDays.abs()} days ${difference.inDays > 0 ? 'from now' : 'ago'}';
    }

    if (difference.inDays.abs() < 365) {
      final months = (difference.inDays.abs() / 30).floor();
      return '$months months ${difference.inDays > 0 ? 'from now' : 'ago'}';
    }

    final years = (difference.inDays.abs() / 365).floor();
    return '$years years ${difference.inDays > 0 ? 'from now' : 'ago'}';
  }
}

/// BuildContext Extensions
extension BuildContextExtensions on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if device is in portrait mode
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  /// Check if device is in landscape mode
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show loading dialog
  void showLoadingDialog({String message = 'Loading...'}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Hide current dialog
  void hideDialog() {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    }
  }

  /// Navigate to a new screen
  Future<T?> navigateTo<T>(Widget screen) {
    return Navigator.of(this).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Navigate and replace current screen
  Future<T?> navigateReplacement<T>(Widget screen) {
    return Navigator.of(this).pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

/// List Extensions
extension ListExtensions<T> on List<T> {
  /// Add item if not already present
  void addIfNotContains(T item) {
    if (!contains(item)) {
      add(item);
    }
  }

  /// Get item by index safely (returns null if index out of bounds)
  T? getSafe(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  /// Split list into chunks
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = i + size > length ? length : i + size;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
}

/// Map Extensions
extension MapExtensions<K, V> on Map<K, V> {
  /// Get value safely with default
  V getSafe(K key, V defaultValue) {
    return containsKey(key) ? this[key]! : defaultValue;
  }

  /// Convert map to query string
  String toQueryString() {
    return entries
        .map((entry) => '${Uri.encodeComponent(entry.key.toString())}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');
  }
}