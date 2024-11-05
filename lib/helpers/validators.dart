// validators.dart

class Validators {
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username is required';
    } else if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
