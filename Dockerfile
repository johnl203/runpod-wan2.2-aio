# Base Image mit CUDA
FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04

# Grundinstallation
RUN apt-get update && apt-get install -y \
    git wget python3-pip ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# ComfyUI klonen
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Python Dependencies
RUN pip install --upgrade pip
RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128
RUN pip install -r ComfyUI/requirements.txt

RUN git clone https://github.com/ltdrdata/ComfyUI-Manager /workspace/ComfyUI/custom_nodes/comfyui-manager
RUN pip install /workspace/ComfyUI/custom_nodes/comfyui-manager/requirements.txt

# VideoHelperSuite als Custom Node installieren
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git /workspace/ComfyUI/custom_nodes/VideoHelperSuite
RUN pip install /workspace/ComfyUI/custom_nodes/VideoHelperSuite/requirements.txt

# Workflow in user/default/workflows kopieren
RUN mkdir -p ComfyUI/user/default/workflows
RUN wget -O ComfyUI/user/default/workflows/wan2.2-i2v-rapid-aio-example.json \
    "https://huggingface.co/Phr00t/WAN2.2-14B-Rapid-AllInOne/resolve/main/wan2.2-i2v-rapid-aio-example.json"

# Entrypoint
COPY entrypoint.sh /workspace/entrypoint.sh
RUN chmod +x /workspace/entrypoint.sh
ENTRYPOINT ["/workspace/entrypoint.sh"]