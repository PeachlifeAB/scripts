#!/usr/bin/env bash
set -euo pipefail

MODEL_DIR="$HOME/models"
LLAMA_DIR="$HOME/llamacpp/llama-turboquant"

PROFILES="1. Qwen 3.6 27B (VLM - Flagship Coding)
2. Qwen 3.6 35B A3B (LLM - Heavy Reasoning)
3. Qwen 3.5 0.8B (VLM - Fast Vision)
4. Qwen 2 0.5B (LLM - Lightning Fast)"

SELECTED=$(echo "$PROFILES" | fzf --height=~50% --layout=reverse --prompt="Boot Profile: ")

[[ -z "$SELECTED" ]] && exit 0

CMD=("./build/bin/llama-server" "-ngl" "99" "--port" "8020")

case "$SELECTED" in
1.*)
    CMD+=("-m" "$MODEL_DIR/bartowski/Qwen_Qwen3.6-27B-GGUF/Qwen_Qwen3.6-27B-Q4_K_S.gguf")
    CMD+=("--mmproj" "$MODEL_DIR/bartowski/Qwen_Qwen3.6-27B-GGUF/mmproj-Qwen_Qwen3.6-27B-f16.gguf")
    CMD+=("--alias" "qwen3.6-27b-vlm")
    CMD+=("-ctk" "q8_0" "-ctv" "q8_0")
    CMD+=("-c" "262144")
    ;;
2.*)
    CMD+=("-m" "$MODEL_DIR/majentik/Qwen3.6-35B-A3B-RotorQuant-GGUF-IQ4_XS/Qwen3.6-35B-A3B-IQ4_XS.gguf")
    CMD+=("--alias" "qwen3.6-35b")
    CMD+=("-ctk" "q8_0" "-ctv" "q8_0")
    CMD+=("-c" "131072") # Capped at 128k so the larger 35B model fits in your M5 Pro
    ;;
3.*)
    CMD+=("-m" "$MODEL_DIR/lmstudio-community/Qwen3.5-0.8B-GGUF/Qwen3.5-0.8B-Q8_0.gguf")
    CMD+=("--mmproj" "$MODEL_DIR/lmstudio-community/Qwen3.5-0.8B-GGUF/mmproj-Qwen3.5-0.8B-BF16.gguf")
    CMD+=("--alias" "qwen3.5-0.8b-vlm")
    CMD+=("-c" "0") # Auto-detect native context
    ;;
4.*)
    CMD+=("-m" "$MODEL_DIR/Qwen/Qwen2-0.5B-Instruct-GGUF/qwen2-0_5b-instruct-q8_0.gguf")
    CMD+=("--alias" "qwen2-0.5b")
    CMD+=("-c" "0") # Auto-detect native context
    ;;
esac

tailscale serve --bg localhost:8020

cd "$LLAMA_DIR"
exec "${CMD[@]}"
