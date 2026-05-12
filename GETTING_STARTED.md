# OTP Listener - Getting Started Guide

Welcome to the OTP Listener application! This is a production-ready Flutter Android app for capturing and forwarding SMS OTP messages to your backend.

## ⚡ Quick Start (5 Minutes)

### 1. Prerequisites
- Android device or emulator (Android 5.0+)
- Flutter SDK installed
- Backend URL ready (or use a local test server)

### 2. Run the App

```bash
# Navigate to project
cd /home/jidu/summer2026/indigo

# Install dependencies
flutter pub get

# Run on device
flutter run
```

### 3. Configure

1. Open app → Go to **Settings** tab
2. Enter your backend URL (e.g., `https://your-api.com/otp`)
3. Toggle **OTP Listener** to ON
4. Grant SMS permissions when prompted

### 4. Test

Send a test SMS to your device:
```
Your OTP is 123456. Valid for 10 minutes.
```

Check the **Logs** tab to see if it was captured!

---

## 📁 What's Inside?

### Complete File List

```
indigo/
├── 📄 README_PRODUCTION.md        # Full documentation
├── 📄 DEPLOYMENT_GUIDE.md         # Deployment & setup
├── 📄 BACKEND_EXAMPLES.md         # Backend code examples
├── 📄 pubspec.yaml                # Dependencies
├── 📁 lib/
│   ├── main.dart                  # App entry point
│   ├── 📁 models/
│   │   ├── otp_message.dart      # OTP data model
│   │   ├── app_settings.dart     # Settings model
│   │   └── sync_log.dart         # Sync log model
│   ├── 📁 services/
│   │   ├── settings_service.dart     # Settings storage
│   │   ├── otp_extractor.dart        # OTP detection
│   │   ├── sync_service.dart         # Backend sync
│   │   └── sms_listener_service.dart # SMS listening
│   ├── 📁 providers/
│   │   └── app_provider.dart     # State management
│   ├── 📁 screens/
│   │   ├── home_screen.dart      # Status screen
│   │   ├── logs_screen.dart      # Message logs
│   │   └── settings_screen.dart  # Configuration
│   └── 📁 theme/
│       └── app_theme.dart        # Dark theme
└── 📁 android/
    ├── AndroidManifest.xml       # Permissions
    └── 📁 kotlin/
        ├── MainActivity.kt        # Flutter activity
        └── SmsReceiver.kt        # SMS receiver
```

---

## 🔧 Configuration Guide

### Backend URL Format

Your backend needs a POST endpoint that accepts OTP data:

**Endpoint:** `POST /otp`

**Expected Request:**
```json
{
  "sender": "+1234567890",
  "message": "Your verification code is 123456",
  "otp": "123456",
  "timestamp": "2026-05-11T10:30:00.000Z"
}
```

**Expected Response:**
```json
{
  "status": "success",
  "message": "OTP received"
}
```

### Backend Setup Options

#### Option 1: Node.js (Fastest)
```bash
# Create simple server
npm init -y
npm install express

# Create server.js
cat > server.js << 'EOF'
const express = require('express');
const app = express();

app.use(express.json());

app.post('/otp', (req, res) => {
  console.log('OTP:', req.body);
  res.json({ status: 'success' });
});

app.listen(3000, () => console.log('Server running on port 3000'));
EOF

# Run
node server.js
```

#### Option 2: Python (Simple)
```bash
pip install flask

cat > server.py << 'EOF'
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/otp', methods=['POST'])
def receive_otp():
    print('OTP:', request.json)
    return jsonify({'status': 'success'})

if __name__ == '__main__':
    app.run(port=3000)
EOF

python server.py
```

#### Option 3: Use Webhook Service
- **Webhook.site** (Free testing): https://webhook.site
- **RequestBin**: https://requestbin.com
- **ngrok** (Tunnel localhost): `ngrok http 3000`

For detailed backend examples in multiple languages, see **BACKEND_EXAMPLES.md**

---

## 📱 Screen Guide

### 1. Status Screen
- **Shows:** Current service status
- **Actions:** View statistics, check configuration
- **Best for:** Quick overview of app health

### 2. Logs Screen
- **Shows:** All captured OTP messages
- **Features:** Copy OTP, view full message, clear history
- **Best for:** Debugging and verification

### 3. Settings Screen
- **Configuration:** Backend URL, enable/disable
- **Info:** Expected payload format
- **Best for:** Setup and troubleshooting

---

## 🔑 Key Features

### Automatic OTP Detection
- ✅ Extracts 4-8 digit codes
- ✅ Keyword matching (OTP, code, verification, etc.)
- ✅ Pattern-based detection
- ✅ Multiple regex patterns

### Reliable Backend Sync
- ✅ Automatic retry (3 times)
- ✅ 5-second delays between retries
- ✅ 30-second timeout
- ✅ Comprehensive error handling

### User-Friendly UI
- ✅ Dark modern theme
- ✅ Real-time status
- ✅ Message history
- ✅ Error messages

---

## 🚀 Advanced Usage

### Testing Without Real SMS

1. **Via Android Debugger:**
```bash
adb shell
am startservice -a com.android.intent.action.SIM_STATE_CHANGED
```

2. **Via Emulator Messages:**
Use Android Studio's emulator telephony simulation

3. **Via Webhook:**
Use https://webhook.site to see requests

### Enable Logging

Check the console logs for detailed debugging:
```
[INFO] OTP extracted: 123456
[DEBUG] Sending OTP to backend
[INFO] OTP sent successfully to backend
```

### Customize OTP Patterns

Edit `lib/services/otp_extractor.dart`:
```dart
static final List<RegExp> _otpPatterns = [
    RegExp(r'your_pattern_here'),
    // Add more patterns
];
```

---

## ⚙️ Building for Release

### For Testing
```bash
flutter run -d <device_id>
```

### For Distribution
```bash
# Build APK (Install on phone)
flutter build apk --release

# Build App Bundle (For Play Store)
flutter build appbundle --release
```

### Sign with Your Key
Create `android/key.properties`:
```properties
storeFile=../key.jks
storePassword=your_password
keyAlias=key
keyPassword=your_password
```

---

## 🐛 Troubleshooting

### SMS Not Being Detected
- [ ] Check SMS permission granted
- [ ] Verify message contains OTP keywords
- [ ] Look at app logs in Settings
- [ ] Test with sample message: "Your OTP is 123456"

### Backend Not Receiving Data
- [ ] Verify URL is accessible
- [ ] Check network connectivity
- [ ] Test with: `curl http://localhost:3000/otp -X POST -H "Content-Type: application/json" -d '{"sender":"+1234567890","message":"Test 123456","otp":"123456","timestamp":"2026-05-11T10:30:00Z"}'`
- [ ] Check backend logs

### App Crashes
```bash
# Clear and reinstall
flutter clean
flutter pub get
flutter run
```

### Permission Issues
```bash
# Uninstall and reinstall
adb uninstall com.otp.listener.indigo
flutter run
```

---

## 📊 Statistics Tracked

- **Total Messages**: Count of captured SMS
- **OTPs Captured**: Count of successfully extracted OTPs
- **Status**: Service active/inactive
- **Backend URL**: Currently configured endpoint

---

## 🔐 Security Notes

1. **Use HTTPS** for production backend
2. **Validate** all inputs on backend
3. **Rate limit** API endpoints
4. **Expire OTPs** after 10 minutes
5. **Log** all OTP requests
6. **Don't expose** sensitive data in logs

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `README_PRODUCTION.md` | Complete technical documentation |
| `DEPLOYMENT_GUIDE.md` | Setup and deployment instructions |
| `BACKEND_EXAMPLES.md` | Backend code in multiple languages |
| `GETTING_STARTED.md` | This file |

---

## ❓ FAQ

**Q: Does it work offline?**
A: No, it requires internet to send OTPs to backend. Logs are saved locally though.

**Q: Can I use a different backend framework?**
A: Yes! Any framework that can handle HTTP POST. See BACKEND_EXAMPLES.md

**Q: How long are OTPs stored?**
A: In app memory and local SharedPreferences. Clear from Logs screen anytime.

**Q: Can I modify OTP patterns?**
A: Yes, edit `lib/services/otp_extractor.dart` and rebuild.

**Q: Is the app open source?**
A: See project license documentation.

---

## 🎯 Next Steps

1. ✅ Install and run the app
2. ✅ Configure backend URL
3. ✅ Test with sample OTP
4. ✅ Deploy to production
5. ✅ Monitor backend requests

---

## 📞 Support

For detailed troubleshooting and advanced configuration:
- Check `README_PRODUCTION.md` for technical details
- Review `BACKEND_EXAMPLES.md` for backend setup
- See app logs in Settings screen for error messages

---

## 📦 Project Details

- **Language**: Dart/Flutter
- **Platform**: Android 5.0+
- **Architecture**: Clean Architecture with Providers
- **Status**: Production Ready
- **Version**: 1.0.0
- **Package**: com.otp.listener.indigo

---

**Ready to start?** Run `flutter run` and configure your backend URL in Settings! 🎉
