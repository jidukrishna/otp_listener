class OtpExtractor {
  // Common OTP patterns
  static final List<RegExp> _otpPatterns = [
    // 4-6 digit OTP
    RegExp(r'\b(\d{4,6})\b'),
    // OTP: 123456
    RegExp(r'OTP[:\s]+(\d{4,6})'),
    // Code: 123456
    RegExp(r'[Cc]ode[:\s]+(\d{4,6})'),
    // Verification code: 123456
    RegExp(r'[Vv]erification[:\s]+(\d{4,6})'),
    // PIN: 123456
    RegExp(r'PIN[:\s]+(\d{4,6})'),
    // Your code: 123456
    RegExp(r'[Yy]our[:\s]+(?:code|OTP)[:\s]+(\d{4,6})'),
    // 6-digit pattern at start or after common prefixes
    RegExp(r'^.*?(\d{6}).*$', multiLine: true),
  ];

  static const List<String> _otpKeywords = [
    'otp',
    'code',
    'verification',
    'verify',
    'confirm',
    'authenticate',
    'password',
    'pin',
    'token',
    'login',
    'signin',
    'auth',
    'reset',
    'confirm',
    'validate',
  ];

  /// Checks if a message is likely an OTP message
  static bool isOtpMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    for (final keyword in _otpKeywords) {
      if (lowerMessage.contains(keyword)) {
        return true;
      }
    }
    
    return false;
  }

  /// Extracts OTP from message text
  static String? extractOtp(String message) {
    if (!isOtpMessage(message)) {
      return null;
    }

    for (final pattern in _otpPatterns) {
      final match = pattern.firstMatch(message);
      if (match != null && match.groupCount > 0) {
        final otp = match.group(1);
        if (otp != null && otp.length >= 4 && otp.length <= 8) {
          // Additional validation: should be all digits
          if (RegExp(r'^\d+$').hasMatch(otp)) {
            return otp;
          }
        }
      }
    }

    return null;
  }

  /// Extracts all potential OTPs from message
  static List<String> extractAllOtps(String message) {
    final otps = <String>{};

    for (final pattern in _otpPatterns) {
      final matches = pattern.allMatches(message);
      for (final match in matches) {
        if (match.groupCount > 0) {
          final otp = match.group(1);
          if (otp != null && otp.length >= 4 && otp.length <= 8) {
            if (RegExp(r'^\d+$').hasMatch(otp)) {
              otps.add(otp);
            }
          }
        }
      }
    }

    return otps.toList();
  }
}
