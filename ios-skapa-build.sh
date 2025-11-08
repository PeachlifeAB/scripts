#!/bin/bash
# ios-skapa-build - Configure xcode-build-server for Skapa iOS project
# Usage: ios-skapa-build

set -euo pipefail

echo "Configuring project for xcode-build-server"
pushd "$HOME/Developer/Skapa/ios-skapa/Example" > /dev/null
xcode-build-server config -project SkapaExample.xcodeproj -scheme SkapaExample
popd > /dev/null
