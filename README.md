# OTP Listener - Production-Ready Flutter Application

A production-grade Flutter Android application that listens for incoming SMS OTP messages, extracts OTP codes using intelligent regex patterns, and forwards them to a configurable backend URL with retry logic and comprehensive logging.


## Download from the release section
Disable play protect when installing it

## Features

✅ **SMS OTP Listening**
- Real-time SMS interception and processing
- Automatic OTP code extraction using regex patterns
- Intelligent filtering of OTP-related messages
- Background SMS listening capability

✅ **Backend Integration**
- Configurable backend URL via UI
- HTTP POST requests with comprehensive payload
- Automatic retry logic with exponential backoff
- Error handling and logging

✅ **User Interface**
- Modern dark theme with Material Design 3
- Three main screens: Status, Logs, Settings
- Real-time OTP message history
- Configuration management
- Status indicators and statistics

✅ **Data Management**
- Local storage using SharedPreferences
- OTP message history tracking
- Settings persistence
- Clean architecture with services

✅ **Performance & Reliability**
- Null safety enabled
- Clean code architecture
- Comprehensive error handling
- Retry mechanism with configurable delays
- Logging system for debugging

## Project Structure
```
otp_listener/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── models/
│   │   ├── otp_message.dart     # OTP message model
│   │   ├── app_settings.dart    # App settings model
│   │   └── sync_log.dart        # Sync logging model
│   ├── services/
│   │   ├── settings_service.dart     # Settings management
│   │   ├── otp_extractor.dart        # OTP extraction logic
│   │   ├── sync_service.dart         # Backend sync service
│   │   └── sms_listener_service.dart # SMS listening service
│   ├── providers/
│   │   └── app_provider.dart    # State management
│   ├── screens/
│   │   ├── home_screen.dart     # Main home screen
│   │   ├── logs_screen.dart     # OTP history logs
│   │   └── settings_screen.dart # Configuration screen
│   └── theme/
│       └── app_theme.dart       # Dark theme configuration
├── android/
│   └── app/src/main/
│       ├── kotlin/com/otp/listener/otp_listener/
│       │   ├── MainActivity.kt   # Flutter activity with SMS event channel
│       │   └── SmsReceiver.kt    # Broadcast receiver for SMS
│       └── AndroidManifest.xml   # Android permissions & receivers
└── pubspec.yaml                 # Flutter dependencies
```


## Android Permissions

The application requires the following permissions (automatically requested at runtime):

```xml
<!-- SMS Permissions -->
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.SEND_SMS" />

<!-- Internet Permission -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Background Execution -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

## Setup Instructions

### Prerequisites
- Flutter 3.10.7 or higher
- Android SDK 21+
- Kotlin 1.7+

### Installation

1. **Clone/Navigate to project**
   ```bash
   git clone https://github.com/jidukrishna/otp_listener.git
   cd otp_listener
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Connect Android device or emulator**
   ```bash
   flutter devices
   ```

4. **Run the application**
   ```bash
   flutter run -d <device_id>
   ```

### Configuration

1. **Open Settings tab** in the application
2. **Enter Backend URL** (e.g., `https://your-backend.com/otp`)
3. **Enable OTP Listener** toggle
4. Permissions will be requested automatically

## Backend Integration

### Expected Endpoint

Your backend should expose an HTTP POST endpoint to receive OTP messages:

```
POST /otp
Content-Type: application/json
```

### Payload Format

```json
{
  "sender": "+1234567890",
  "message": "Your OTP is 123456. Valid for 10 minutes.",
  "otp": "123456",
  "timestamp": "2026-05-11T10:30:00.000Z"
}
```

### Response

The application expects a 2xx status code for success:

```json
{
  "status": "success",
  "message": "OTP received"
}
```

### Error Handling

- **Retry Logic**: 3 automatic retries with 5-second delays
- **Timeout**: 30 seconds per request
- **Client Errors (4xx)**: No retry, logged as error
- **Server Errors (5xx)**: Automatic retry with backoff

## OTP Detection

The application uses intelligent regex patterns to detect OTP codes:

### Supported Patterns

1. **4-6 digit numbers**: `\b(\d{4,6})\b`
2. **OTP: 123456** format
3. **Code: 123456** format
4. **Verification code: 123456**
5. **PIN: 123456**
6. **Your code/OTP: 123456**

### Keywords for OTP Detection

The message must contain at least one of these keywords (case-insensitive):
- otp, code, verification, verify, confirm, authenticate
- password, pin, token, login, signin, auth, reset, validate



## Logging

The application uses the `logger` package for comprehensive logging:

```dart
logger.i('Info message');
logger.d('Debug information');
logger.w('Warning message');
logger.e('Error message', error: exception);
```

All logs are displayed in console during development.


## Testing

### Manual Testing

1. **Enable in Settings**
   - Configure a test backend URL
   - Enable the listener

2. **Send Test SMS**
   - Send an SMS with OTP content
   - Verify detection in Logs

3. **Verify Backend**
   - Check if backend receives the payload
   - Verify all fields are present



## Security Considerations

1. **Permissions**: Only SMS and network permissions required
2. **Data**: Backend URL and settings stored locally
3. **Network**: HTTPS recommended for backend communication
4. **Validation**: URL format validation before saving
5. **Error Handling**: Sensitive errors logged but not exposed

## Troubleshooting

### SMS not being detected
- Ensure SMS permissions are granted
- Check if message contains OTP keywords
- Verify regex patterns match your OTP format
- Check logs for error messages

### Backend not receiving OTPs
- Verify backend URL is correct and accessible
- Check network connectivity
- Review error messages in logs
- Ensure backend endpoint is correctly configured

### App crashes on startup
- Clear app data: `flutter clean`
- Reinstall: `flutter pub get && flutter run`
- Check permissions in Android settings

## Building for Release

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### Signing

Ensure you have a valid keystore configured in `android/key.properties`:

```properties
storeFile=<path-to-keystore>
storePassword=<keystore-password>
keyAlias=<key-alias>
keyPassword=<key-password>
```

## Version Information

- **App Version**: 1.0.0
- **Build Number**: 1
- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: Latest
- **Flutter Version**: 3.10.7+

## License

This project is provided as-is for production use.

## Support

For issues and feature requests, refer to the application logs and error messages displayed in the Settings screen. 
