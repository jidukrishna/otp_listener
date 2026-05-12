import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/otp_message.dart';
import 'otp_extractor.dart';
import 'settings_service.dart';
import 'sync_service.dart';

class SmsListenerService {
  static const _smsChannel = EventChannel('com.otp.listener/sms');

  final SettingsService _settingsService;
  final SyncService _syncService = SyncService();
  final Logger _logger = Logger();

  StreamSubscription? _smsSubscription;
  final StreamController<OtpMessage> _otpMessageController =
      StreamController<OtpMessage>.broadcast();

  SmsListenerService({required SettingsService settingsService})
      : _settingsService = settingsService;

  Stream<OtpMessage> get otpMessageStream => _otpMessageController.stream;

  /// Request SMS permissions and start listening
  Future<bool> initialize() async {
    try {
      _logger.i('Initializing SMS listener service');

      // Request permissions
      final status = await Permission.sms.request();
      if (!status.isGranted) {
        _logger.w('SMS permission denied');
        return false;
      }

      _startListening();
      _logger.i('SMS listener initialized successfully');
      return true;
    } catch (e) {
      _logger.e('Error initializing SMS listener', error: e);
      return false;
    }
  }

  void _startListening() {
    _smsSubscription?.cancel();
    _smsSubscription = _smsChannel.receiveBroadcastStream().listen(
      (dynamic event) async {
        try {
          final data = Map<String, dynamic>.from(event as Map);
          final sender = data['sender'] as String? ?? '';
          final message = data['message'] as String? ?? '';
          final timestampMs = data['timestamp'] as int? ?? 0;
          final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);

          await processSmsMessage(
            sender: sender,
            messageBody: message,
            timestamp: timestamp,
          );
        } catch (e) {
          _logger.e('Error handling SMS event', error: e);
        }
      },
      onError: (dynamic error) {
        _logger.e('SMS channel error', error: error);
      },
    );
  }

  /// Process an incoming SMS — extract OTP and forward to backend
  Future<void> processSmsMessage({
    required String sender,
    required String messageBody,
    required DateTime timestamp,
  }) async {
    try {
      _logger.d('Processing SMS from: $sender');

      if (!OtpExtractor.isOtpMessage(messageBody)) {
        _logger.d('Not an OTP message, skipping');
        return;
      }

      final otp = OtpExtractor.extractOtp(messageBody);
      if (otp == null) {
        _logger.d('Could not extract OTP from message');
        return;
      }

      _logger.i('OTP extracted: $otp from $sender');

      final otpMessage = OtpMessage(
        sender: sender,
        message: messageBody,
        otp: otp,
        timestamp: timestamp,
      );

      _otpMessageController.add(otpMessage);

      final settings = await _settingsService.getSettings();
      if (settings.isEnabled && settings.backendUrl.isNotEmpty) {
        _logger.d('Sending OTP to backend: ${settings.backendUrl}');
        final success = await _syncService.sendOtpToBackend(
          backendUrl: settings.backendUrl,
          otpMessage: otpMessage,
        );
        _logger.i('Backend sync ${success ? 'succeeded' : 'failed'}');
      }
    } catch (e) {
      _logger.e('Error processing SMS message', error: e);
    }
  }

  Future<void> dispose() async {
    await _smsSubscription?.cancel();
    await _otpMessageController.close();
    _logger.i('SMS listener disposed');
  }
}