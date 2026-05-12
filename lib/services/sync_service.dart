import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/otp_message.dart';

class SyncService {
  final Logger _logger = Logger();
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);

  /// Sends OTP data to backend with retry logic
  Future<bool> sendOtpToBackend({
    required String backendUrl,
    required OtpMessage otpMessage,
  }) async {
    if (backendUrl.isEmpty) {
      _logger.w('Backend URL is empty');
      return false;
    }

    int retries = 0;
    Exception? lastError;

    while (retries < maxRetries) {
      try {
        _logger.d('Sending OTP to backend (attempt ${retries + 1}/$maxRetries)');

        final response = await http
            .post(
              Uri.parse(backendUrl),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode({
                'sender': otpMessage.sender,
                'message': otpMessage.message,
                'otp': otpMessage.otp,
                'timestamp': otpMessage.timestamp.toIso8601String(),
              }),
            )
            .timeout(const Duration(seconds: 30));

        _logger.d('Backend response: ${response.statusCode}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          _logger.i('OTP sent successfully to backend');
          return true;
        } else if (response.statusCode >= 400 && response.statusCode < 500) {
          // Client error, don't retry
          _logger.e('Client error from backend: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        lastError = e as Exception;
        _logger.e('Error sending OTP to backend', error: e);
      }

      retries++;
      if (retries < maxRetries) {
        _logger.d('Retrying in ${retryDelay.inSeconds} seconds...');
        await Future.delayed(retryDelay);
      }
    }

    _logger.e('Failed to send OTP after $maxRetries retries', error: lastError);
    return false;
  }

  /// Sends multiple OTP messages to backend
  Future<Map<String, bool>> sendMultipleOtps({
    required String backendUrl,
    required List<OtpMessage> otpMessages,
  }) async {
    final results = <String, bool>{};

    for (final message in otpMessages) {
      final id = '${message.sender}_${message.timestamp.millisecondsSinceEpoch}';
      final success = await sendOtpToBackend(
        backendUrl: backendUrl,
        otpMessage: message,
      );
      results[id] = success;
      
      // Add small delay between requests to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }

  /// Validates backend URL format
  static bool isValidBackendUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'http' || uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }
}
