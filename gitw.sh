#!/usr/bin/env zsh
set -euo pipefail

show_help() {
    cat <<EOF
gitw [options]

Create a git worktree for the current repository and open a shell in it.

Options:
    -b, --branch NAME    Branch name for the worktree
    -h, --help           Show this help

Examples:
    gitw --branch feature/my-work
    gitw -b fix/login-loop
    gitw

EOF
    exit 0
}

branch=""

while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        show_help
        ;;
    -b | --branch)
        [[ -n "${2:-}" ]] || {
            echo "Error: $1 requires a branch name" >&2
            exit 1
        }
        branch="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Error: unknown argument: $1" >&2
        exit 1
        ;;
    esac
done

groot="$(git rev-parse --show-toplevel)"
proj="$(basename "$groot")"

if [[ -z "$branch" ]]; then
    if ! command -v gum >/dev/null 2>&1; then
        echo "Error: --branch was not provided and gum is not installed" >&2
        exit 1
    fi

    default_branch="$(date "+%Y%m%d%H%M%S")"
    branch="$(gum input \
        --header "Branch name for new worktree" \
        --placeholder "$default_branch")"

    if [[ -z "$branch" ]]; then
        branch="$default_branch"
    fi
fi

dir="../worktrees/$proj/$branch"

if [[ -e "$dir" ]]; then
    echo "Error: destination already exists: $dir" >&2
    exit 1
fi

mkdir -p "$(dirname "$dir")"

cd "$groot"

if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$dir" "$branch"
else
    git worktree add -b "$branch" "$dir"
fi

worktree_path="$(cd "$dir" && pwd)"

echo "worktree created at:"
echo "$worktree_path"

# cd "$worktree_path"
escaped_worktree_path=${worktree_path//\\/\\\\}
escaped_worktree_path=${escaped_worktree_path//\"/\\\"}

osascript <<APPLESCRIPT
tell application "Ghostty"
    activate
    set cfg to new surface configuration
    set initial working directory of cfg to "$escaped_worktree_path"
    set w to new window with configuration cfg
end tell
APPLESCRIPT
