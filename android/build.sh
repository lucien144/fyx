#!/bin/bash
set -e

# Get to the project dir
cd "$(dirname "$0")"
cd ..

# Find and increment the version number.
perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' pubspec.yaml

version=`grep 'version: ' pubspec.yaml | sed 's/version: //'`
echo "Building version: $version"
flutter clean
flutter build appbundle -t lib/main_production.dart
open build/app/outputs/bundle/release/