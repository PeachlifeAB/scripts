#!/usr/bin/env bash

set -euo pipefail

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

found_exact=()
found_fuzzy=()
found_pkg_manager=()
found_nvim_configured=()
found_mason=()

# Associative array to track found linters (for deduplication)
declare -A found_map

# Function to check if linter is already found
is_already_found() {
    local linter_name=$1
    [ "${found_map[$linter_name]:-}" = "1" ] && return 0
    return 1
}

# Function to mark as found
mark_found() {
    found_map[$1]=1
}

echo -e "${BOLD}🔍 Building linter list from Mason registry...${NC}\n"

# Extract linters from mason registry dynamically
mason_registry_path=~/.local/share/nvim/mason/registries/github/mason-org/mason-registry/registry.json
linters_array=()

if [ -f "$mason_registry_path" ]; then
    linters_from_registry=$(python3 -c "
import json
import os
registry_path = os.path.expanduser('$mason_registry_path')
try:
    with open(registry_path) as f:
        registry = json.load(f)
        for pkg in registry:
            if 'categories' in pkg and any(cat in ['Linter', 'Formatter'] for cat in pkg['categories']):
                print(pkg['name'])
except:
    pass
" 2>/dev/null || true)
    
    while IFS= read -r linter; do
        [ -z "$linter" ] && continue
        linters_array+=("$linter")
    done <<<"$linters_from_registry"
fi

# Fallback to hardcoded list if registry not available
if [ ${#linters_array[@]} -eq 0 ]; then
    linters_array=(
        "coala" "commitlint" "megalinter"
        "ansible-lint" "awesome-lint"
        "clang-format" "clang-tidy" "cppcheck" "cpplint" "oclint" "uncrustify"
        "coffeelint" "ameba"
        "csslint" "csscomb" "ie8linter" "stylelint"
        "csvlint" "dartanalyzer"
        "dockerfile_lint" "dockerfilelint" "hadolint"
        "credo" "elm-review"
        "alex" "proselint" "textlint"
        "dotenv-linter" "epubcheck" "elvis"
        "golangci-lint" "golint" "gometalinter"
        "graphql-schema-linter"
        "npm-groovy-lint" "hlint" "haxe-checkstyle"
        "htmlhint" "html-validate" "bootlint" "jinjalint" "linthtml"
        "checkstyle" "findbugs" "pmd"
        "clinton" "eslint" "jshint" "prettier" "putout" "quick-lint-js" "standard" "xo"
        "ktlint"
        "luacheck" "lualint"
        "markdownlint" "markdownlint-cli" "mdl" "remark-lint"
        "lockfile-lint" "npmPkgJsonLint"
        "speccy"
        "perlcritic" "perltidy"
        "phplint" "phpmd" "polylint" "pug-lint" "puppet-lint"
        "black" "flake8" "pycodestyle" "pep8" "pylint" "ruff" "wemake-python-styleguide" "yala"
        "regal" "doc8" "rst-lint" "rubocop"
        "clippy" "cargo-clippy"
        "salt-lint"
        "sass-lint" "scss-lint"
        "scalastyle" "scapegoat"
        "shellcheck" "shfmt"
        "sqlfluff"
        "swiftlint" "swiftformat"
        "tslint"
        "spectral" "yamllint"
    )
fi

echo -e "${BOLD}🔍 Scanning for linters (found ${#linters_array[@]} in registry)...${NC}\n"

# Quick scan: check for exact matches first
for linter in "${linters_array[@]}"; do
    if command -v "$linter" &>/dev/null; then
        path=$(command -v "$linter")
        found_exact+=("$linter|$path|exact")
        mark_found "$linter"
    fi
done

echo -e "${GRAY}Scanning package managers...${NC}"

# Check Homebrew installed formulae for linters
if command -v brew &>/dev/null; then
    brew_linters=$(brew list --formula 2>/dev/null | rg "lint|format|check|analyzer|tidy" || true)
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        if ! is_already_found "$pkg"; then
            if command -v "$pkg" &>/dev/null; then
                path=$(command -v "$pkg")
                found_pkg_manager+=("$pkg|$path|brew")
                mark_found "$pkg"
            fi
        fi
    done <<<"$brew_linters"
fi

# Check npm global packages
if command -v npm &>/dev/null; then
    npm_linters=$(npm list -g 2>/dev/null | rg -o "'[^']+'" | tr -d "'" | rg "lint|format|check" | sort -u || true)
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        if ! is_already_found "$pkg"; then
            if command -v "$pkg" &>/dev/null; then
                path=$(command -v "$pkg")
                found_pkg_manager+=("$pkg|$path|npm")
                mark_found "$pkg"
            fi
        fi
    done <<<"$npm_linters"
fi

# Check Python installed packages
if command -v python3 &>/dev/null; then
    python_linters=$(python3 -m pip list 2>/dev/null | rg -i "lint|flake|black|ruff|pylint|mypy|autopep8" | awk '{print $1}' || true)
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        pkg_lower=$(echo "$pkg" | tr '[:upper:]' '[:lower:]' | tr '_' '-')
        if ! is_already_found "$pkg_lower"; then
            if command -v "$pkg_lower" &>/dev/null 2>&1; then
                path=$(command -v "$pkg_lower")
                found_pkg_manager+=("$pkg_lower|$path|python")
                mark_found "$pkg_lower"
            fi
        fi
    done <<<"$python_linters"
fi

# Check Cargo installed packages
if [ -d ~/.cargo/bin ] && command -v fd &>/dev/null; then
    cargo_linters=$(fd -H '.' ~/.cargo/bin -d 1 -t f | xargs basename -a | rg "lint|check|format" || true)
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        if ! is_already_found "$pkg"; then
            found_pkg_manager+=("$pkg|$HOME/.cargo/bin/$pkg|cargo")
            mark_found "$pkg"
        fi
    done <<<"$cargo_linters"
fi

# Check RubyGems installed packages
if command -v gem &>/dev/null; then
    gem_linters=$(gem list 2>/dev/null | rg "lint|check|format" | awk '{print $1}' | sort -u || true)
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        if ! is_already_found "$pkg"; then
            if command -v "$pkg" &>/dev/null 2>&1; then
                path=$(command -v "$pkg")
                found_pkg_manager+=("$pkg|$path|gem")
                mark_found "$pkg"
            fi
        fi
    done <<<"$gem_linters"
fi

# Extract linters from nvim-lint config
if [ -f ~/.config/nvim/lua/plugins/nvim-lint.lua ]; then
    nvim_linters=$(rg 'linters_by_ft\.[a-z]+ = \{ "([^"]+)"' ~/.config/nvim/lua/plugins/nvim-lint.lua -o -r '$1' | sort -u || true)
    while IFS= read -r linter; do
        [ -z "$linter" ] && continue
        if ! is_already_found "$linter"; then
            if command -v "$linter" &>/dev/null 2>&1; then
                path=$(command -v "$linter")
                found_nvim_configured+=("$linter|$path|nvim-lint")
                mark_found "$linter"
            fi
        fi
    done <<<"$nvim_linters"
fi

# Extract formatters from conform config
if [ -f ~/.config/nvim/lua/plugins/conform.lua ]; then
    nvim_formatters=$(rg 'formatters_by_ft\.[a-z]+ = \{ "([^"]+)"' ~/.config/nvim/lua/plugins/conform.lua -o -r '$1' | sort -u || true)
    while IFS= read -r formatter; do
        [ -z "$formatter" ] && continue
        if ! is_already_found "$formatter"; then
            if command -v "$formatter" &>/dev/null 2>&1; then
                path=$(command -v "$formatter")
                found_nvim_configured+=("$formatter|$path|conform")
                mark_found "$formatter"
            fi
        fi
    done <<<"$nvim_formatters"
fi

# Extract from mason packages directory
if [ -d ~/.local/share/nvim/mason/packages ]; then
    mason_packages=$(fd -H '.' ~/.local/share/nvim/mason/packages -d 1 -t d | xargs basename -a | sort -u)
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        if ! is_already_found "$pkg"; then
            # Try to find the actual command in the package
            if [ -d ~/.local/share/nvim/mason/packages/"$pkg"/bin ]; then
                bin_path=$(ls -1 ~/.local/share/nvim/mason/packages/"$pkg"/bin 2>/dev/null | head -1)
                if [ -n "$bin_path" ]; then
                    full_path="$HOME/.local/share/nvim/mason/packages/$pkg/bin/$bin_path"
                    found_mason+=("$pkg|$full_path|mason")
                    mark_found "$pkg"
                fi
            elif command -v "$pkg" &>/dev/null 2>&1; then
                path=$(command -v "$pkg")
                found_mason+=("$pkg|$path|mason")
                mark_found "$pkg"
            fi
        fi
    done <<<"$mason_packages"
fi

# Display exact matches
if [ ${#found_exact[@]} -gt 0 ]; then
    echo -e "\n${GREEN}${BOLD}✓ Exact matches (${#found_exact[@]}):${NC}\n"

    for entry in "${found_exact[@]}"; do
        IFS='|' read -r name path type <<<"$entry"
        echo -e "${GREEN}✓${NC} ${BOLD}$name${NC}"
        echo -e "  ${GRAY}→ $path${NC}"
    done
fi

# Display fuzzy matches
if [ ${#found_fuzzy[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}${BOLD}⚠ Fuzzy matches (${#found_fuzzy[@]}):${NC}\n"

    for entry in "${found_fuzzy[@]}"; do
        IFS='|' read -r name path type original <<<"$entry"
        echo -e "${YELLOW}~${NC} ${BOLD}$name${NC} ${GRAY}(similar to: $original)${NC}"
        echo -e "  ${GRAY}→ $path${NC}"
    done
fi

# Display package manager found linters
if [ ${#found_pkg_manager[@]} -gt 0 ]; then
    echo -e "\n${BOLD}${GRAY}📦 Found via package managers (${#found_pkg_manager[@]}):${NC}\n"

    for entry in "${found_pkg_manager[@]}"; do
        IFS='|' read -r name path source <<<"$entry"
        echo -e "${BOLD}$name${NC} ${GRAY}[$source]${NC}"
        echo -e "  ${GRAY}→ $path${NC}"
    done
fi

# Display Neovim configured linters
if [ ${#found_nvim_configured[@]} -gt 0 ]; then
    echo -e "\n${BOLD}${GRAY}🎨 Neovim configured (${#found_nvim_configured[@]}):${NC}\n"

    for entry in "${found_nvim_configured[@]}"; do
        IFS='|' read -r name path source <<<"$entry"
        plugin_name=""
        if [ "$source" = "nvim-lint" ]; then
            plugin_name="${GRAY}(nvim-lint)${NC}"
        elif [ "$source" = "conform" ]; then
            plugin_name="${GRAY}(conform)${NC}"
        fi
        echo -e "${BOLD}$name${NC} $plugin_name"
        echo -e "  ${GRAY}→ $path${NC}"
    done
fi

# Display Mason installed linters
if [ ${#found_mason[@]} -gt 0 ]; then
    echo -e "\n${BOLD}${GRAY}🏗️  Neovim Mason (${#found_mason[@]}):${NC}\n"

    for entry in "${found_mason[@]}"; do
        IFS='|' read -r name path source <<<"$entry"
        echo -e "${BOLD}$name${NC} ${GRAY}[mason]${NC}"
        echo -e "  ${GRAY}→ $path${NC}"
    done
fi

# Summary
total_found=$((${#found_exact[@]} + ${#found_fuzzy[@]} + ${#found_pkg_manager[@]} + ${#found_nvim_configured[@]} + ${#found_mason[@]}))
echo ""
if [ $total_found -eq 0 ]; then
    echo -e "${RED}✗ No linters found${NC}"
else
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GRAY}Registry: ${#linters_array[@]} linters${NC}"
    echo -e "${GREEN}Exact: ${#found_exact[@]}${NC} | ${YELLOW}Fuzzy: ${#found_fuzzy[@]}${NC} | ${GRAY}Pkg Mgr: ${#found_pkg_manager[@]}${NC} | ${GRAY}Config: ${#found_nvim_configured[@]}${NC} | ${GRAY}Mason: ${#found_mason[@]}${NC} | ${BOLD}Total: $total_found${NC}"
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi
