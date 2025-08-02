// lib/core/utils/validators.dart
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation with requirements
  static String? validatePasswordWeak(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      "Password must be at least 6 characters long";
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    // Check for special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Simple password validation (for login)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    // Check if contains only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return '$fieldName can only contain letters and spaces';
    }

    return null;
  }

  // OTP validation
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP can only contain numbers';
    }

    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }

    if (age < 16 || age > 120) {
      return 'Age must be between 16 and 120';
    }

    return null;
  }

  // URL validation
  static String? validateURL(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional in most cases
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Password confirmation validation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Custom validation for specific patterns
  static String? validatePattern(
    String? value,
    RegExp pattern,
    String errorMessage,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (!pattern.hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }

  // Length validation
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }
}
