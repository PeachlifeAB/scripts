#!/usr/bin/env bash
PORT=8080
MODEL="mlx-community/Qwen3.5-27B-Claude-4.6-Opus-Distilled-MLX-4bit"

if ! curl -s "http://localhost:${PORT}/v1/models" >/dev/null 2>&1; then
    echo "🔥 Starting mlx_lm server..."
    mlx_lm server --model "$MODEL" --port "$PORT" >/tmp/mlx_lm.log 2>&1 &
    echo $! >/tmp/mlx_lm.pid
    echo -n "⏳ Waiting"
    until curl -s "http://localhost:${PORT}/v1/models" >/dev/null 2>&1; do
        echo -n "."
        sleep 1
    done
    echo " ✓ Ready"
fi

forge "$@"
