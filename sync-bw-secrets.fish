#!/usr/bin/env fish
# sync-bw-secrets.fish
# One-time or scheduled sync of Bitwarden secrets to universal fish variables
# Usage: sync-bw-secrets.fish [--force]
# 
# This script:
# 1. Ensures bw-secrets daemon is running
# 2. Fetches all secrets via bw-secrets env
# 3. Stores each as a universal fish variable (persisted across shells)
# 4. Subsequent shells load instantly from ~/.local/share/fish/fish_variables
#
# Run with --force to re-sync even if variables already exist

set force_sync 0
if test (count $argv) -gt 0
    and string match -q -- --force $argv[1]
    set force_sync 1
end

# Start daemon if not running
if not string match -q "*running*" (bw-secrets status)
    echo "Starting bw-secrets daemon..."
    bw-secrets start
    sleep 0.1
end

# Check if secrets already synced (unless --force)
if test $force_sync -eq 0; and set -q ANTHROPIC_API_KEY
    echo "Secrets already synced. Use --force to re-sync."
    return 0
end

echo "Syncing Bitwarden secrets to universal variables..."
set start_time (date +%s%3N)

# Parse bw-secrets env output and set as universal variables
bw-secrets env | while read -l line
    if string match -q "export *" $line
        # Extract variable name and value
        # Format: export VAR_NAME=value
        set parts (string match -r '^export ([^=]+)=(.*)$' $line)
        if test (count $parts) -ge 3
            set var_name $parts[2]
            set var_value $parts[3]
            # Remove surrounding quotes if present
            set var_value (string trim -c \" $var_value)
            
            # Set as universal variable (persisted across shells)
            set -Ux $var_name $var_value
            echo "  ✓ $var_name"
        end
    end
end

set end_time (date +%s%3N)
set elapsed (math "$end_time - $start_time")
echo "✓ Synced secrets in ${elapsed}ms"
