#!/bin/bash
# build.sh - Update Xcode project version numbers
# Usage: build.sh [--marketing-version VERSION] [--build-version VERSION] [--project PATH]

set -euo pipefail

# Colors for output
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Help text
show_help() {
    cat <<EOF
bump.sh [options]

Update Xcode project version numbers

Options:
  -h, --help                      show help
  -m, --marketing-version VERSION marketing version [0-9].[0-9].[0-999]
  -b, --build-version VERSION     build version [0-999]
  -p, --project PATH              .xcodeproj file path

Examples:
  bump.sh
  bump.sh --marketing-version 1.2.345 --build-version 42
  bump.sh -m 2.0.1 -b 100 -p MyApp.xcodeproj

EOF
    exit 0
}

# Validate marketing version format: [0-9].[0-9].[0-999]
validate_marketing_version() {
    local version="$1"
    if [[ $version =~ ^[0-9]\.[0-9]\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Validate project version format: [0-999]
validate_project_version() {
    local version="$1"
    if [[ $version =~ ^[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Parse flags
marketing_version=""
project_version=""
xcodeproj=""

while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
        show_help
        ;;
    -m | --marketing-version)
        marketing_version="$2"
        shift 2
        ;;
    -b | --build-version)
        project_version="$2"
        shift 2
        ;;
    -p | --project)
        xcodeproj="$2"
        shift 2
        ;;
    *)
        echo -e "${RED}❌ Unknown option: $1${RESET}"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
done

# Find first .xcodeproj (excluding Pods/)
default_xcodeproj=$(fd -e xcodeproj -E Pods/ | head -n 1 || true)

if [[ -z "$default_xcodeproj" ]]; then
    echo -e "${RED}❌ No .xcodeproj found in current directory${RESET}"
    exit 1
fi

# Prompt for MARKETING_VERSION if not provided
if [[ -z "$marketing_version" ]]; then
    while true; do
        echo -n "Enter MARKETING_VERSION [0-9].[0-9].[0-999]: "
        read -r marketing_version
        
        if validate_marketing_version "$marketing_version"; then
            echo -e "${GREEN}✓ Valid marketing version: $marketing_version${RESET}"
            break
        else
            echo -e "${RED}❌ Invalid format. Must be [0-9].[0-9].[0-999] (e.g., 1.2.345)${RESET}"
        fi
    done
else
    # Validate provided marketing version
    if ! validate_marketing_version "$marketing_version"; then
        echo -e "${RED}❌ Invalid marketing version format: $marketing_version${RESET}"
        echo -e "${RED}   Must be [0-9].[0-9].[0-999] (e.g., 1.2.345)${RESET}"
        exit 1
    fi
    echo -e "${GREEN}✓ Using marketing version: $marketing_version${RESET}"
fi

# Prompt for CURRENT_PROJECT_VERSION if not provided
if [[ -z "$project_version" ]]; then
    while true; do
        echo -n "Enter CURRENT_PROJECT_VERSION [0-999]: "
        read -r project_version
        
        if validate_project_version "$project_version"; then
            echo -e "${GREEN}✓ Valid project version: $project_version${RESET}"
            break
        else
            echo -e "${RED}❌ Invalid format. Must be [0-999] (e.g., 42)${RESET}"
        fi
    done
else
    # Validate provided project version
    if ! validate_project_version "$project_version"; then
        echo -e "${RED}❌ Invalid build version format: $project_version${RESET}"
        echo -e "${RED}   Must be [0-999] (e.g., 42)${RESET}"
        exit 1
    fi
    echo -e "${GREEN}✓ Using build version: $project_version${RESET}"
fi

# Prompt for .xcodeproj file if not provided (with default)
if [[ -z "$xcodeproj" ]]; then
    echo -n "Enter .xcodeproj file path [$default_xcodeproj]: "
    read -r xcodeproj_input
    
    # Use default if empty
    xcodeproj="${xcodeproj_input:-$default_xcodeproj}"
else
    echo -e "${GREEN}✓ Using project: $xcodeproj${RESET}"
fi

# Validate xcodeproj exists
if [[ ! -d "$xcodeproj" ]]; then
    echo -e "${RED}❌ .xcodeproj not found: $xcodeproj${RESET}"
    exit 1
fi

# Path to project.pbxproj
pbxproj="$xcodeproj/project.pbxproj"

if [[ ! -f "$pbxproj" ]]; then
    echo -e "${RED}❌ project.pbxproj not found in: $xcodeproj${RESET}"
    exit 1
fi

echo -e "\n${YELLOW}Updating version numbers in $pbxproj...${RESET}"

# Update MARKETING_VERSION
sd 'MARKETING_VERSION = .*;' "MARKETING_VERSION = $marketing_version;" "$pbxproj"
echo -e "${GREEN}✓ Updated MARKETING_VERSION to $marketing_version${RESET}"

# Update CURRENT_PROJECT_VERSION
sd 'CURRENT_PROJECT_VERSION = .*;' "CURRENT_PROJECT_VERSION = $project_version;" "$pbxproj"
echo -e "${GREEN}✓ Updated CURRENT_PROJECT_VERSION to $project_version${RESET}"

echo -e "\n${GREEN}✨ Build version update complete!${RESET}"
