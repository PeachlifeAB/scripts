#!/bin/bash
# openfile - Search and open files with fzf preview
set -euo pipefail

cd "$HOME"

# Function to open file with appropriate app
open_file() {
    local file="$1"
    echo "DEBUG: Opening file: $file" >&2
    case "$file" in
        *.pdf)
            echo "DEBUG: Detected PDF, opening with Preview" >&2
            open -a Preview "$file"
            ;;
        *.xcodeproj|*.xcworkspace)
            echo "DEBUG: Detected Xcode project, opening with Xcode" >&2
            open -a Xcode "$file"
            ;;
        *)
            echo "DEBUG: Opening with nvim" >&2
            nvim "$file"
            ;;
    esac
}

# Create a temporary wrapper script
WRAPPER=$(mktemp)
cat > "$WRAPPER" << 'EOF'
#!/bin/bash
file="$1"
echo "DEBUG: Opening file: $file" >&2
case "$file" in
    *.pdf)
        echo "DEBUG: Detected PDF, opening with Preview" >&2
        open -a Preview "$file"
        ;;
    *.xcodeproj|*.xcworkspace)
        echo "DEBUG: Detected Xcode project, opening with Xcode" >&2
        open -a Xcode "$file"
        ;;
    *)
        echo "DEBUG: Opening with nvim" >&2
        nvim "$file"
        ;;
esac
EOF
chmod +x "$WRAPPER"

# Run fzf and clean up wrapper on exit
trap "rm -f $WRAPPER" EXIT

fd | fzf \
    --preview 'bat --color=always {}' \
    --preview-window=right:50% \
    --bind "enter:execute($WRAPPER {})+abort"
