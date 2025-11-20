#!/bin/bash

# GRead Android TV Build Script
# This script builds the app for Android TV

echo "🎬 Building GRead for Android TV..."
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build APK for Android TV
echo "🔨 Building APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📱 APK Location:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📺 To install on Android TV:"
    echo "   1. Enable Developer options on your Android TV"
    echo "   2. Enable ADB debugging"
    echo "   3. Connect via ADB: adb connect <TV_IP_ADDRESS>"
    echo "   4. Install: adb install build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "🎮 You can also sideload using apps like:"
    echo "   - File Commander"
    echo "   - X-plore File Manager"
    echo "   - Send Files to TV"
    echo ""
else
    echo "❌ Build failed!"
    exit 1
fi
