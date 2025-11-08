#!/bin/bash
# xcodegen-dump.sh - Dump all xcodeproj-cli list commands to dump.txt
# Usage: xcodegen-dump.sh

OUTPUT="dump.txt"

# Clear or create output file
>"$OUTPUT"

echo "=== xcodeproj-cli list-groups ===" >>"$OUTPUT"
xcodeproj-cli list-groups >>"$OUTPUT" 2>&1
echo "" >>"$OUTPUT"

echo "=== xcodeproj-cli list-targets ===" >>"$OUTPUT"
xcodeproj-cli list-targets >>"$OUTPUT" 2>&1
echo "" >>"$OUTPUT"

echo "=== xcodeproj-cli list-build-settings ===" >>"$OUTPUT"
xcodeproj-cli list-build-settings >>"$OUTPUT" 2>&1
echo "" >>"$OUTPUT"

echo "=== xcodeproj-cli list-build-configs ===" >>"$OUTPUT"
xcodeproj-cli list-build-configs >>"$OUTPUT" 2>&1
echo "" >>"$OUTPUT"

echo "=== xcodeproj-cli list-swift-packages ===" >>"$OUTPUT"
xcodeproj-cli list-swift-packages >>"$OUTPUT" 2>&1
echo "" >>"$OUTPUT"

echo "=== xcodeproj-cli list-files ===" >>"$OUTPUT"
xcodeproj-cli list-files >>"$OUTPUT" 2>&1
echo "" >>"$OUTPUT"

echo "=== xcodeproj-cli list-tree ===" >>"$OUTPUT"
xcodeproj-cli list-tree >>"$OUTPUT" 2>&1
echo "" >>"$OUTPUT"

echo "=== xcodeproj-cli list-invalid-references ===" >>"$OUTPUT"
xcodeproj-cli list-invalid-references >>"$OUTPUT" 2>&1
echo "" >>"$OUTPUT"

echo "=== xcodeproj-cli list-schemes ===" >>"$OUTPUT"
xcodeproj-cli list-schemes >>"$OUTPUT" 2>&1
echo "" >>"$OUTPUT"

echo "=== xcodeproj-cli list-workspace-projects ===" >>"$OUTPUT"
xcodeproj-cli list-workspace-projects >>"$OUTPUT" 2>&1

echo "Dump complete: $OUTPUT"

