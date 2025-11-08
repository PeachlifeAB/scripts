#!/bin/bash
# va - Open nvim with opencode toggle
# Usage: va

set -euo pipefail

nvim -c 'lua require("opencode").toggle()'
