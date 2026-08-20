#!/bin/bash
set -e

# If running from repo root, enter frontend directory where Flutter project resides
if [ -d "frontend" ] && [ -f "frontend/pubspec.yaml" ]; then
  cd frontend
fi

# 1. Clone the Flutter SDK (stable branch, depth 1) into a local flutter folder
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK (stable branch)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
fi

# 2. Disable Flutter analytics
echo "Disabling Flutter analytics..."
./flutter/bin/flutter config --no-analytics

# 3. Fetch dependencies
echo "Fetching dependencies with flutter pub get..."
./flutter/bin/flutter pub get

# 4. Build release version for web
echo "Building Flutter web release bundle..."
./flutter/bin/flutter build web --release
