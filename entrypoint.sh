#!/usr/bin/env bash
set -euo pipefail

# Venv aktivieren
source /workspace/venv/bin/activate

echo "==> Starte Initialisierung"

# --- Workflow-Download ---
if [[ -n "${HF_WORKFLOW_URL:-}" ]]; then
  mkdir -p "$WORKFLOW_DIR"
  TARGET_WF="$WORKFLOW_DIR/$HF_WORKFLOW_FILENAME"
  if [[ -f "$TARGET_WF" ]]; then
    echo "==> Workflow existiert bereits: $TARGET_WF"
  else
    echo "==> Lade Workflow: $HF_WORKFLOW_URL"
    wget -O "$TARGET_WF" "$HF_WORKFLOW_URL"
    echo "==> Workflow gespeichert: $TARGET_WF"
  fi
else
  echo "==> Kein Workflow angegeben – überspringe."
fi

# --- Modell-Download ---
if [[ -n "${HF_MODEL_URL:-}" ]]; then
  mkdir -p "$MODEL_DIR"
  TARGET="$MODEL_DIR/$HF_FILENAME"
  if [[ -f "$TARGET" ]]; then
    echo "==> Modell existiert bereits: $TARGET"
  else
    echo "==> Lade Modell: $HF_MODEL_URL"
    wget -O "$TARGET" "$HF_MODEL_URL"
    echo "==> Modell gespeichert: $TARGET"
  fi
else
  echo "==> Kein Modell angegeben – überspringe."
fi

# - Instal Extension pip -
chmod +x /workspace/venv/bin/activate
/workspace/venv/bin/activate
python -m pip install -r ${COMFYUI_ROOT}/custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt

# --- GPU Check (optional) ---
python - <<'PY'
import torch
print("CUDA verfügbar:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU Name:", torch.cuda.get_device_name(0))
    print("CUDA Version:", torch.version.cuda)
    print("Torch Version:", torch.__version__)
PY

echo "==> Starte ComfyUI auf 0.0.0.0:8188"
exec python "${COMFYUI_ROOT}/main.py" --listen 0.0.0.0

