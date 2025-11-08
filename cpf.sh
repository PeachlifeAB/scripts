#!/bin/bash
# cpp - Copy file content to clipboard
# Usage: cpp <file>

set -euo pipefail

cb copy "$@"
echo -e "\033[32mFile content is now in clipboard\033[0m"
