#!/bin/bash
set -e

FLUTTER_PATH="$(pwd)/flutter/bin/flutter"

if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
fi

if [ -f "pubspec.yaml" ]; then
  echo "Building from root directory..."
  $FLUTTER_PATH config --no-analytics
  $FLUTTER_PATH pub get
  $FLUTTER_PATH build web --release
  mkdir -p web
  cp -r build/web/* web/
elif [ -f "frontend/pubspec.yaml" ]; then
  echo "Building from frontend directory..."
  cd frontend
  ../flutter/bin/flutter config --no-analytics
  ../flutter/bin/flutter pub get
  ../flutter/bin/flutter build web --release
  cd ..
  mkdir -p web
  cp -r frontend/build/web/* web/
else
  echo "Error: pubspec.yaml not found!"
  exit 1
fi

echo "Successfully prepared web folder for Vercel!"
