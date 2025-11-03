#!/bin/bash

# Build Flutter web app
echo "Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful! Deploying to Firebase..."
    firebase deploy --only hosting
else
    echo "Build failed! Please fix errors and try again."
    exit 1
fi

