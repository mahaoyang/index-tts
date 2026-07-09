#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

MODEL_DIR="${MODEL_DIR:-checkpoints}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-7860}"
GUI_SEG_TOKENS="${GUI_SEG_TOKENS:-120}"
CUDA_TEST="${CUDA_TEST:-0}"
FP16="${FP16:-0}"
DEEPSPEED="${DEEPSPEED:-0}"
CUDA_KERNEL="${CUDA_KERNEL:-0}"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv not found. Install uv first, then rerun this script." >&2
  exit 1
fi

if [[ ! -d "$MODEL_DIR" ]]; then
  echo "Model directory not found: $MODEL_DIR" >&2
  exit 1
fi

for required in bpe.model gpt.pth config.yaml s2mel.pth wav2vec2bert_stats.pt; do
  if [[ ! -e "$MODEL_DIR/$required" ]]; then
    echo "Required model file missing: $MODEL_DIR/$required" >&2
    exit 1
  fi
done

if [[ "$CUDA_TEST" == "1" ]]; then
  exec uv run --extra webui python - <<'PY'
import torch
print(torch.__version__, torch.version.cuda)
print(torch.cuda.is_available(), torch.cuda.get_device_name(0) if torch.cuda.is_available() else None)
print(torch.ones(1, device="cuda").item())
PY
fi

args=(
  webui.py
  --model_dir "$MODEL_DIR"
  --host "$HOST"
  --port "$PORT"
  --gui_seg_tokens "$GUI_SEG_TOKENS"
)

if [[ "$FP16" == "1" ]]; then
  args+=(--fp16)
fi

if [[ "$DEEPSPEED" == "1" ]]; then
  args+=(--deepspeed)
fi

if [[ "$CUDA_KERNEL" == "1" ]]; then
  args+=(--cuda_kernel)
fi

exec uv run --extra webui "${args[@]}" "$@"
