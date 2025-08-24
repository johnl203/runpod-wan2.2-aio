# Base Image mit CUDA
FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y \
    git wget python3-pip python3-venv ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# ComfyUI klonen
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Virtuelles Environment direkt im ComfyUI Ordner
RUN python3 -m venv /workspace/ComfyUI/venv

# pip im venv aktualisieren
RUN /workspace/ComfyUI/venv/bin/pip install --upgrade pip

# Abhängigkeiten installieren
RUN /workspace/ComfyUI/venv/bin/pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128
RUN /workspace/ComfyUI/venv/bin/pip install -r /workspace/ComfyUI/requirements.txt

# VideoHelperSuite als Custom Node
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /workspace/ComfyUI/custom_nodes/VideoHelperSuite
RUN /workspace/ComfyUI/venv/bin/pip install -r /workspace/ComfyUI/custom_nodes/VideoHelperSuite/requirements.txt

# ComfyUI Manager installieren
RUN /workspace/ComfyUI/venv/bin/pip install git+https://github.com/comfyanonymous/ComfyUI-Manager.git

# clip_vision Modell separat installieren
RUN mkdir -p /workspace/ComfyUI/models/clip_vision
RUN wget -O /workspace/ComfyUI/models/clip_vision/clip_vision_h.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"

# Workflow in user/default/workflows kopieren
RUN mkdir -p /workspace/ComfyUI/user/default/workflows
RUN wget -O /workspace/ComfyUI/user/default/workflows/wan2.2-i2v-rapid-aio-example.json \
    "https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/wan2.2-i2v-rapid-aio-example.json"

# Entrypoint
COPY entrypoint.sh /workspace/entrypoint.sh
RUN chmod +x /workspace/entrypoint.sh
ENTRYPOINT ["/workspace/entrypoint.sh"]
