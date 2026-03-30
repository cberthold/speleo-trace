#!/bin/bash

# Build script for Speleo Trace

set -e

echo "Building Speleo Trace..."

# Install dependencies
flutter pub get

# Run tests
flutter test

# Build APK
flutter build apk --release

# Build iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    flutter build ios --release
fi

echo "Build completed successfully!"