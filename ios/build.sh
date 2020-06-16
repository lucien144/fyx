#!/bin/bash
set -e

# Get to the project dir
cd "$(dirname "$0")"
cd ..

# Find and increment the version number.
perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' pubspec.yaml

version=`grep 'version: ' pubspec.yaml | sed 's/version: //'`
echo "Building version: $version"
flutter build ios -t lib/main_production.dart