FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_CACHE_DIR=/workspace/.cache/pip

# 시스템 패키지 및 빌드 도구 + Jupyter 필수 툴 설치
RUN apt-get update && apt-get install -y \
    git wget curl ffmpeg libgl1 \
    build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev libncurses5-dev \
    libncursesw5-dev xz-utils tk-dev libffi-dev \
    liblzma-dev software-properties-common \
    locales sudo tzdata xterm nano \
    nodejs npm && \
    apt-get clean

# 정확한 Python 3.10.6 소스 설치 + pip 심볼릭 링크 추가
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tgz && \
    tar xzf Python-3.10.6.tgz && cd Python-3.10.6 && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && make altinstall && \
    ln -sf /usr/local/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -sf /usr/local/bin/pip3.10 /usr/bin/pip && \
    ln -sf /usr/local/bin/pip3.10 /usr/local/bin/pip && \
    cd / && rm -rf /tmp/*

# ComfyUI 설치
WORKDIR /workspace
RUN mkdir -p /workspace && chmod -R 777 /workspace && \
    chown -R root:root /workspace
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
WORKDIR /workspace/ComfyUI

# 의존성 설치
RUN pip install -r requirements.txt && \
    pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu126

# Node.js 18 설치 (기존 nodejs 제거 후)
RUN apt-get remove -y nodejs npm && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

# JupyterLab 안정 버전 설치
RUN pip install --force-reinstall jupyterlab==3.6.6 jupyter-server==1.23.6

# Jupyter 설정파일 보완
RUN mkdir -p /root/.jupyter && \
    echo "c.ServerApp.allow_origin = '*'\n\
c.ServerApp.ip = '0.0.0.0'\n\
c.ServerApp.open_browser = False\n\
c.ServerApp.token = ''\n\
c.ServerApp.password = ''\n\
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}" \
> /root/.jupyter/jupyter_notebook_config.py

# segment-anything 설치
RUN git clone https://github.com/facebookresearch/segment-anything.git /workspace/segment-anything || echo '⚠️ segment-anything 실패' && \
    pip install -e /workspace/segment-anything || echo '⚠️ segment-anything pip 설치 실패'

# ReActor ONNX 모델 설치
RUN mkdir -p /workspace/ComfyUI/models/insightface && \
    wget -O /workspace/ComfyUI/models/insightface/inswapper_128.onnx \
    https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/inswapper_128.onnx || echo '⚠️ ONNX 다운로드 실패'

# 공통 파이썬 패키지 설치
RUN pip install --no-cache-dir \
    GitPython onnx onnxruntime opencv-python-headless tqdm requests \
    scikit-image piexif packaging transformers accelerate peft sentencepiece \
    protobuf scipy einops pandas matplotlib imageio[ffmpeg] pyzbar pillow numba \
    gguf diffusers insightface dill || echo '⚠️ 일부 pip 설치 실패' && \
    pip install facelib==0.2.2 mtcnn==0.1.1 || echo '⚠️ facelib 실패' && \
    pip install facexlib basicsr gfpgan realesrgan || echo '⚠️ facexlib 실패' && \
    pip install timm ultralytics ftfy bitsandbytes xformers || echo '⚠️ 기타 패키지 실패'

# 자동 커스텀 노드 설치 스크립트 복사
COPY init_or_check_nodes.sh /workspace/init_or_check_nodes.sh
RUN chmod +x /workspace/init_or_check_nodes.sh

# Hugging Face 모델 다운로드 스크립트 복사
COPY Hugging_down_a1.sh /workspace/Hugging_down_a1.sh
RUN chmod +x /workspace/Hugging_down_a1.sh


# 데이터 볼륨 마운트 경로 설정 (추가 보존 디렉토리)
VOLUME ["/workspace"]

# 포트 설정
EXPOSE 8188
EXPOSE 8888

# 실행 명령어 – 자동 노드 설치 후 Jupyter & ComfyUI 실행
CMD bash -c "\
bash /workspace/init_or_check_nodes.sh && \
jupyter lab --ip=0.0.0.0 --port=8888 --allow-root \
--ServerApp.token='' --ServerApp.password='' & \
python /workspace/ComfyUI/main.py --listen 0.0.0.0 --port=8188 \
--front-end-version Comfy-Org/ComfyUI_frontend@latest & \
wait; echo 'A1(AI는 에이원) : https://www.youtube.com/@A01demort'"
