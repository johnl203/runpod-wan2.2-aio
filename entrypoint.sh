#!/bin/bash
set -e

echo "Starting ComfyUI..."

# WAN2.2 Modell herunterladen, falls nicht vorhanden
MODEL_PATH=ComfyUI/models/checkpoints/wan2.2-i2v-rapid-aio-nsfw-v9.2.safetensors
mkdir -p $(dirname $MODEL_PATH)

if [ ! -f "$MODEL_PATH" ]; then
    echo "WAN2.2 model not found, downloading..."
    wget -c --progress=dot:giga -O $MODEL_PATH \
    "https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v9/wan2.2-i2v-rapid-aio-nsfw-v9.2.safetensors"
fi

# clip_vision Modell separat installieren
mkdir -p ComfyUI/models/clip_vision
wget -O ComfyUI/models/clip_vision/clip_vision_h.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"

# Start ComfyUI
python3 ComfyUI/main.py --listen 0.0.0.0