#!/bin/bash

echo "Cloning or updating Flutter..."
if cd flutter; then 
  git pull
  cd ..
else 
  git clone https://github.com/flutter/flutter.git -b stable
fi

export PATH="$PATH:`pwd`/flutter/bin"

echo "Running flutter doctor..."
flutter doctor

echo "Cleaning..."
flutter clean

echo "Configuring web..."
flutter config --enable-web

echo "Building web..."
flutter build web --release
