# OTP Listener - Deployment Guide

## Quick Start

### 1. Build the Application

```bash
cd /home/jidu/summer2026/indigo

# For development/debug build
flutter run -d <device_id>

# For release APK
flutter build apk --release

# For App Bundle (Play Store)
flutter build appbundle --release
```

### 2. Installation on Android

**Via Flutter:**
```bash
flutter install
```

**Via ADB:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Via Play Store:**
Upload the `.aab` file from `build/app/outputs/bundle/release/app-release.aab`

### 3. Initial Configuration

1. Launch the app
2. Navigate to **Settings** tab
3. Enter your backend URL (e.g., `https://api.example.com/otp`)
4. Toggle **Enable OTP Listener** ON
5. Grant SMS permissions when prompted

## Project Structure Overview

```
indigo/
├── android/                          # Android native code
│   ├── app/
│   │   ├── build.gradle.kts         # App build configuration
│   │   └── src/main/
│   │       ├── AndroidManifest.xml  # Permissions & receivers
│   │       └── kotlin/
│   │           ├── MainActivity.kt   # Flutter activity
│   │           └── SmsReceiver.kt    # SMS broadcast receiver
│   ├── build.gradle.kts             # Project configuration
│   └── settings.gradle.kts          # Settings
├── lib/                             # Dart/Flutter code
│   ├── main.dart                    # App entry point
│   ├── models/                      # Data models
│   │   ├── otp_message.dart        # OTP message model
│   │   ├── app_settings.dart       # Settings model
│   │   └── sync_log.dart           # Sync log model
│   ├── services/                    # Business logic
│   │   ├── settings_service.dart   # Settings management
│   │   ├── otp_extractor.dart      # OTP extraction logic
│   │   ├── sync_service.dart       # Backend sync
│   │   └── sms_listener_service.dart # SMS listening
│   ├── providers/                   # State management
│   │   └── app_provider.dart       # Main provider
│   ├── screens/                     # UI screens
│   │   ├── home_screen.dart        # Home/status screen
│   │   ├── logs_screen.dart        # Message logs
│   │   └── settings_screen.dart    # Configuration
│   └── theme/                       # UI theming
│       └── app_theme.dart          # Dark theme config
├── pubspec.yaml                     # Flutter dependencies
└── README_PRODUCTION.md             # Full documentation
```

## File-by-File Explanation

### Android Files

#### `android/app/src/main/AndroidManifest.xml`
- Declares SMS permissions
- Registers SMS broadcast receiver
- Configures main activity
- Sets up internet and background execution permissions

#### `android/app/src/main/kotlin/com/otp/listener/indigo/MainActivity.kt`
- Flutter main activity
- Sets up SMS EventChannel for communication
- Handles incoming SMS broadcasts from Android receiver

#### `android/app/src/main/kotlin/com/otp/listener/indigo/SmsReceiver.kt`
- Broadcast receiver for incoming SMS
- Extracts sender, message body, and timestamp
- Forwards data to Flutter via event channel

### Dart/Flutter Files

#### `lib/main.dart`
- Application entry point
- Initializes MultiProvider for state management
- Sets up theme and routes

#### `lib/models/`
- **otp_message.dart**: Represents an OTP-containing SMS
- **app_settings.dart**: Stores backend URL and enabled state
- **sync_log.dart**: Tracks sync operations

#### `lib/services/`
- **settings_service.dart**: Persists settings using SharedPreferences
- **otp_extractor.dart**: Regex-based OTP detection logic
- **sync_service.dart**: HTTP client for backend communication with retry logic
- **sms_listener_service.dart**: Coordinates SMS processing and backend sync

#### `lib/providers/app_provider.dart`
- Main state provider using ChangeNotifier
- Manages app state and user interactions
- Coordinates all services

#### `lib/screens/`
- **home_screen.dart**: Main screen with status indicators and statistics
- **logs_screen.dart**: Display message history
- **settings_screen.dart**: Configure backend URL and enable/disable service

#### `lib/theme/app_theme.dart`
- Centralized dark theme configuration
- Material Design 3 compliant
- Custom color scheme

## API Payload Format

### Request to Your Backend

```json
POST /otp HTTP/1.1
Host: your-backend.com
Content-Type: application/json
Content-Length: 256

{
  "sender": "+1234567890",
  "message": "Your verification code is 123456. Valid for 10 minutes.",
  "otp": "123456",
  "timestamp": "2026-05-11T10:30:45.123Z"
}
```

### Expected Response

```json
HTTP/1.1 200 OK
Content-Type: application/json

{
  "status": "success",
  "message": "OTP processed"
}
```

## Configuration

### Backend URL Format

The URL should be a valid HTTPS or HTTP endpoint:

```
https://api.example.com/otp          ✓ Valid
https://example.com:8080/api/otp     ✓ Valid
http://localhost:3000/otp            ✓ Valid (for testing)
example.com/otp                       ✗ Invalid (missing scheme)
htp://example.com/otp                ✗ Invalid (wrong scheme)
```

### OTP Detection Rules

Messages are detected as OTPs if they contain:

1. **At least one keyword** (case-insensitive):
   - otp, code, verification, verify, confirm, authenticate
   - password, pin, token, login, signin, auth, reset, validate

2. **And contain a digit sequence** of 4-8 digits:
   - Can be standalone: "123456"
   - Or with prefix: "OTP: 123456" or "Code: 123456"

### Retry Configuration

- **Max Retries**: 3 attempts
- **Retry Delay**: 5 seconds between attempts
- **Request Timeout**: 30 seconds
- **Backoff Strategy**: Fixed 5-second delays

## Dependencies

```yaml
# State Management
provider: ^6.1.5+1              # UI state management

# SMS & Telephony
telephony: ^0.2.0               # SMS reading/listening

# Local Storage
shared_preferences: ^2.3.0      # Persistent settings

# Networking
http: ^1.2.0                    # HTTP client

# Background Tasks
workmanager: ^0.5.2             # Background job scheduling

# Logging
logger: ^2.2.0                  # Logging system

# UI (Built-in)
flutter:
  sdk: flutter
cupertino_icons: ^1.0.8         # iOS icons
```

## Android Permissions Explained

```xml
<!-- Read SMS for history -->
<uses-permission android:name="android.permission.READ_SMS" />

<!-- Listen for new SMS -->
<uses-permission android:name="android.permission.RECEIVE_SMS" />

<!-- Can send SMS (if needed) -->
<uses-permission android:name="android.permission.SEND_SMS" />

<!-- Required for HTTP requests -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Check network availability -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- For background scheduling -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

## Environment Setup

### Minimum Requirements

- **OS**: Android 5.0+ (API Level 21+)
- **Flutter**: 3.10.7 or higher
- **Kotlin**: 1.7+
- **Gradle**: 7.0+

### Recommended Setup

```bash
# Verify Flutter installation
flutter --version

# Check Android setup
flutter doctor -v

# Update Flutter
flutter upgrade
```

## Build Variants

### Debug Build
```bash
flutter run -d <device_id>
```
- Fast build
- Full debugging support
- Larger APK size
- Not for release

### Release Build
```bash
flutter build apk --release
```
- Optimized code
- Code minification
- Smaller APK
- Production ready

### Profile Build
```bash
flutter run --profile -d <device_id>
```
- Performance profiling
- Maintains debugging
- For performance testing

## Keystore Setup (For Release)

Create `android/key.properties`:

```properties
storeFile=../key.jks
storePassword=your_store_password
keyAlias=key
keyPassword=your_key_password
```

Create keystore:
```bash
keytool -genkey -v -keystore ../key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

## Testing Checklist

- [ ] SMS permissions granted
- [ ] SMS received and detected
- [ ] OTP extracted correctly
- [ ] Backend URL configured
- [ ] HTTP request sent successfully
- [ ] Settings persist after restart
- [ ] Error handling works
- [ ] UI responsive
- [ ] No crashes on edge cases

## Troubleshooting

### SMS Not Detected

1. Check SMS contains OTP keywords
2. Verify regex pattern matches your OTP format
3. Look at app logs in console
4. Ensure SMS permission granted

### Backend Not Receiving Requests

1. Verify URL is accessible
2. Check network connectivity
3. Review endpoint configuration
4. Check firewall rules

### App Crashes

```bash
# Clear all data
flutter clean

# Reinstall
flutter pub get
flutter run
```

### Permission Issues

```bash
# Reinstall app to re-request permissions
adb uninstall com.otp.listener.indigo
flutter run
```

## Performance Tips

1. Use HTTPS for backend communication
2. Batch multiple OTP sends if possible
3. Implement request timeouts on backend
4. Monitor network usage
5. Log important events only

## Security Best Practices

1. **Use HTTPS** for all backend communication
2. **Validate** backend URL before saving
3. **Handle** sensitive data securely
4. **Sanitize** error messages
5. **Limit** logging of sensitive info
6. **Use** appropriate permissions only
7. **Test** on real devices

## Production Deployment

1. **Testing Phase**
   - Test on multiple Android versions
   - Verify OTP detection patterns
   - Test backend integration
   - Performance testing

2. **Release Phase**
   - Build release APK/AAB
   - Sign with production keystore
   - Upload to Play Store or distribute
   - Monitor for errors

3. **Post-Release**
   - Monitor crash reports
   - Collect user feedback
   - Plan updates
   - Maintain security patches

## Version Information

- **App Name**: OTP Listener
- **Package Name**: com.otp.listener.indigo
- **Version**: 1.0.0
- **Build Number**: 1
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: Latest

## Support & Maintenance

### Regular Updates

```bash
# Check for package updates
flutter pub outdated

# Update packages
flutter pub upgrade

# Update Flutter itself
flutter upgrade
```

### Monitoring

Monitor these metrics post-deployment:
- Crash rate
- OTP detection accuracy
- Backend sync success rate
- Network latency
- User engagement

## Next Steps

1. Configure your backend endpoint
2. Test OTP detection with sample messages
3. Deploy to test devices
4. Verify backend integration
5. Prepare for production release

---

For detailed API documentation and architecture details, see `README_PRODUCTION.md`
