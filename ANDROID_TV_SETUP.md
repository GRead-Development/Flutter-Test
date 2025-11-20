# GRead - Android TV Setup

Your GRead app is now configured to run on Android TV! 🎬📺

## What's Been Configured

1. **AndroidManifest.xml** - Added:
   - `LEANBACK_LAUNCHER` intent filter for TV launcher
   - Android TV feature declarations
   - Touchscreen marked as optional
   - TV banner icon reference

2. **TV Banner** - Created a simple blue banner drawable
   - Located at: `android/app/src/main/res/drawable/ic_banner.xml`
   - You can replace this with a custom 320x180px PNG banner if desired

3. **Build Script** - Created `build_android_tv.sh` for easy building

## Building for Android TV

### Quick Build (Recommended)
```bash
./build_android_tv.sh
```

### Manual Build
```bash
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Installing on Android TV

### Method 1: ADB (Best for Development)
1. On your Android TV:
   - Go to Settings → About
   - Click on "Build" 7 times to enable Developer Options
   - Go to Settings → Developer Options
   - Enable "ADB Debugging"
   - Note your TV's IP address (Settings → Network)

2. On your computer:
```bash
# Connect to your TV
adb connect <TV_IP_ADDRESS>:5555

# Verify connection
adb devices

# Install the app
adb install build/app/outputs/flutter-apk/app-release.apk

# Launch the app (optional)
adb shell am start -n com.example.gread_app/.MainActivity
```

### Method 2: Sideloading Apps
1. Install a file manager on your TV:
   - **File Commander** (recommended)
   - **X-plore File Manager**
   - **Solid Explorer**

2. Transfer the APK to your TV:
   - Use a USB drive, or
   - Use "Send Files to TV" app, or
   - Download from cloud storage

3. Open the file manager on TV and install the APK

### Method 3: Google TV App (if available)
1. Upload APK to Google Drive or Dropbox
2. Access it through the TV's browser or file manager
3. Install directly

## Testing on Android TV

The app will appear in your Android TV launcher as "GRead" with a blue banner.

### Navigation Tips:
- Use the D-pad on your remote for navigation
- Tab navigation will work with remote controls
- Text input will work with remote keyboard or on-screen keyboard

## Customization

### Replace the TV Banner
Replace `android/app/src/main/res/drawable/ic_banner.xml` with a PNG:

1. Create a 320x180px PNG image named `ic_banner.png`
2. Place it in:
   - `android/app/src/main/res/mipmap-xhdpi/ic_banner.png`
   - `android/app/src/main/res/mipmap-xxhdpi/ic_banner.png`
3. Update manifest to use `@mipmap/ic_banner`

### Optimize for TV D-Pad Navigation
Consider adding focus handling for better TV remote experience:
```dart
// In your widgets, add focus nodes for D-pad navigation
FocusNode _focusNode = FocusNode();

// And use:
Focus(
  focusNode: _focusNode,
  child: YourWidget(),
)
```

## TV App Features

Your app now supports:
- ✅ Android TV launcher integration
- ✅ D-pad/remote navigation
- ✅ Touchscreen optional (works with remote only)
- ✅ Same codebase as mobile version

## Troubleshooting

**App doesn't appear in TV launcher:**
- Verify LEANBACK_LAUNCHER is in AndroidManifest.xml
- Rebuild and reinstall the app
- Restart the Android TV device

**Remote navigation doesn't work:**
- Tab order should work automatically with Flutter
- For complex UIs, add explicit focus handling

**Text input is difficult:**
- Android TV will show on-screen keyboard
- Consider adding voice input support for better UX

**App looks stretched/weird:**
- Use responsive layouts with `LayoutBuilder`
- Test on TV screen dimensions (typically 1920x1080)

## Development Tips

1. **Test with Android TV Emulator:**
   ```bash
   # Create Android TV AVD in Android Studio
   # Or use command line:
   flutter emulators --create --name android_tv
   flutter emulators --launch android_tv
   ```

2. **Run in debug mode on TV:**
   ```bash
   adb connect <TV_IP>:5555
   flutter run
   ```

3. **View logs:**
   ```bash
   adb logcat | grep flutter
   ```

## Fun Fact! 🎉

Your reading social network can now be enjoyed from the comfort of your couch on the big screen! Perfect for:
- Browsing your library in 4K
- Checking the activity feed from across the room
- Updating reading progress without picking up your phone

Enjoy GRead on Android TV! 📚📺✨
