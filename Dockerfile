# ---- Basis: CUDA 12.8 Runtime (für Blackwell GPUs) ----
FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# ---- Systempakete ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3 python3-venv python3-pip wget curl ca-certificates \
    libgl1 libglib2.0-0 ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# ---- Arbeitsverzeichnis ----
WORKDIR /workspace

# ---- Python-Venv ----
RUN python3 -m venv /workspace/venv
ENV PATH="/workspace/venv/bin:$PATH"
RUN pip install --upgrade pip setuptools wheel

# ---- PyTorch Nightly mit CUDA 12.8 (Blackwell Support) ----
RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128

# ---- ComfyUI installieren ----
ENV COMFYUI_ROOT=/workspace/ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git ${COMFYUI_ROOT}
RUN pip install --no-cache-dir -r ${COMFYUI_ROOT}/requirements.txt

# ---- Standard-Verzeichnisse ----
ENV MODEL_DIR=${COMFYUI_ROOT}/models/checkpoints \
    WORKFLOW_DIR=${COMFYUI_ROOT}/workflows

RUN mkdir -p ${MODEL_DIR} ${WORKFLOW_DIR}

# ---- Hugging Face URLs (können in RunPod überschrieben werden) ----
ENV HF_MODEL_URL="https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/v9/wan2.2-i2v-rapid-aio-nsfw-v9.2.safetensors" \
    HF_FILENAME="wan2.2-i2v-rapid-aio-nsfw-v9.2.safetensors" \
    HF_WORKFLOW_URL="https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/wan2.2-i2v-rapid-aio-example.json" \
    HF_WORKFLOW_FILENAME="wan2.2-i2v-rapid-aio-example.json"

# ---- Entrypoint kopieren ----
COPY entrypoint.sh /workspace/entrypoint.sh
RUN chmod +x /workspace/entrypoint.sh

# ---- Exposed Port ----
EXPOSE 8188

# ---- Start ComfyUI ----
CMD ["/workspace/entrypoint.sh"]
