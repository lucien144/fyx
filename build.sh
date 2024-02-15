#!/bin/bash
set -e

# CD to the script dir
cd "$(dirname "$0")"

usage() {
  echo "Builds Android and iOS build and bumps up the build number."
  echo ""
  echo "Usage: build.sh [-k] [-i] [-a]"
  echo "  -k: keep the current build number"
  echo "  -i: build ios only"
  echo "  -a: build android only"
  echo ""
}

keep=false
ios=true
android=true

while getopts "kia" o; do
    case "${o}" in
        k)
            keep=true
            ;;
        i)
            ios=true
            android=false
            ;;
        a)
            android=true
            ios=false
            ;;
        *)
            usage
            exit 1;
            ;;
    esac
done

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

version=`grep 'version: ' pubspec.yaml | sed 's/version: //'`
if [ $keep == false ]; then
    # Find and increment the version number.
    perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' pubspec.yaml
    bump=`grep 'version: ' pubspec.yaml | sed 's/version: //'`
    printf "$YELLOW Bumping the version: ${version} -> ${bump}$NC \n"
    version=$bump
fi


if [ $ios == true ]; then
  # shellcheck disable=SC2059
  printf "$GREEN Building iOS: ${version}$NC\n"
  flutter clean
  flutter pub get
  (cd ios && pod cache clean --all && pod update)
  flutter build ios -t lib/main_production.dart
  open ios/Runner.xcworkspace
  /usr/bin/osascript -e "display notification \"iOS built.\""
fi

if [ $android == true ]; then
  # shellcheck disable=SC2059
  printf "$GREEN Building Android: ${version}$NC\n"

  (cd android && ./gradlew clean)

  if [ $ios == false ]; then
    flutter clean
    flutter pub get
  fi

  flutter build appbundle -t lib/main_production.dart
  mv build/app/outputs/bundle/release/app-release.aab "build/app/outputs/bundle/release/fyx-release-${version}.aab"
  open build/app/outputs/bundle/release/
  /usr/bin/osascript -e "display notification \"Android built.\""
fi
