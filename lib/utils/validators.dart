class Validators {
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    // Optional: Add more password strength checks
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // Confirm Password Validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name Validation
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName can only contain letters and spaces';
    }

    return null;
  }

  // Phone Number Validation (Pakistan specific)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove any spaces, dashes, or plus signs
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-+]'), '');

    // Check if it's a valid Pakistan phone number
    final phoneRegex = RegExp(r'^03[0-9]{9}$');
    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Please enter a valid Pakistan phone number (e.g., 03001234567)';
    }

    return null;
  }

  // CNIC Validation (Pakistan)
  static String? validateCNIC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CNIC is required';
    }

    final cleanedCNIC = value.replaceAll(RegExp(r'[\s\-]'), '');

    final cnicRegex = RegExp(r'^[0-9]{13}$');
    if (!cnicRegex.hasMatch(cleanedCNIC)) {
      return 'Please enter a valid 13-digit CNIC number';
    }

    return null;
  }

  // Not Empty Validation
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Number Validation
  static String? validateNumber(String? value, {String fieldName = 'Number', double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }

    if (max != null && number > max) {
      return '$fieldName must be less than or equal to $max';
    }

    return null;
  }

  // Date Validation
  static String? validateDate(String? value, {String fieldName = 'Date'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();

      if (date.isBefore(now)) {
        return '$fieldName cannot be in the past';
      }

      return null;
    } catch (e) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
  }

  // Credit Card Validation
  static String? validateCreditCard(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }

    final cleanedCard = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanedCard.length != 16) {
      return 'Card number must be 16 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedCard)) {
      return 'Card number can only contain digits';
    }

    return null;
  }

  // CVV Validation
  static String? validateCVV(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV is required';
    }

    if (value.length != 3 && value.length != 4) {
      return 'CVV must be 3 or 4 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'CVV can only contain digits';
    }

    return null;
  }

  // Expiry Date Validation
  static String? validateExpiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry date is required';
    }

    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!expiryRegex.hasMatch(value)) {
      return 'Please enter in MM/YY format';
    }

    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');

    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0); // Last day of month

    if (expiryDate.isBefore(now)) {
      return 'Card has expired';
    }

    return null;
  }
}