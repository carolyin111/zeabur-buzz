FROM n8nio/n8n:1.86.1

# 安裝基本依賴
RUN apk update && apk add --no-cache \
    ffmpeg \
    python3 \
    py3-pip \
    git \
    wget \
    build-base \
    python3-dev \
    linux-headers \
    gcc \
    g++ \
    musl-dev \
    libffi-dev \
    openssl-dev \
    libstdc++ \
    && rm -rf /var/cache/apk/*

# 安裝 Python 依賴
RUN pip3 install --no-cache-dir --break-system-packages \
    numpy \
    setuptools-rust \
    ctranslate2>=4.0,<5 \
    faster-whisper==1.0.3

# 設置工作目錄
WORKDIR /root/.n8n

# 設置通用環境變數，支援 Python 和 FFmpeg
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/root/.n8n:/usr/local/lib/python3.12/site-packages \
    PATH=/usr/local/bin:/usr/bin:/bin:/root/.n8n \
    TZ=Asia/Taipei

# 暴露 n8n 端口
EXPOSE 5678

# 切換回 node 用戶
USER node

# 使用原始的啟動命令
CMD ["n8n"]
