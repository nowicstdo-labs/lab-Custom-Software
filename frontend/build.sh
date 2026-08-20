#!/bin/bash
set -e

if [ ! -d "flutter" ]; then
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
fi

echo "Configuring Flutter..."
./flutter/bin/flutter config --no-analytics
./flutter/bin/flutter pub get

echo "Building Flutter Web..."
./flutter/bin/flutter build web --release

echo "Copying files to web directory..."
mkdir -p web
cp -r build/web/* web/

echo "Build and copy completed successfully!"
