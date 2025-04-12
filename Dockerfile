FROM debian:bullseye-slim

# 安裝 Node.js 和 n8n
RUN apt-get update && apt-get install -y \
        curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g n8n@1.86.1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER root

# 安裝基本依賴
RUN apt-get update && apt-get install -y \
        ffmpeg \
        python3 \
        python3-pip \
        python3-dev \
        git \
        wget \
        build-essential \
        libffi-dev \
        libssl-dev \
        libstdc++6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安裝 Python 依賴
RUN pip3 install --no-cache-dir \
        numpy \
        setuptools-rust \
        ctranslate2==4.4.0 \
        faster-whisper==1.0.3

# 設置工作目錄
WORKDIR /root/.n8n

# 複製應用程式檔案（例如 cloud_script.py）
COPY cloud_script.py /root/.n8n/

# 設置通用環境變數，支援 Python 和 FFmpeg
ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/root/.n8n:/usr/local/lib/python3.9/site-packages \
    PATH=/usr/local/bin:/usr/bin:/bin:/root/.n8n \
    TZ=Asia/Taipei

# 暴露 n8n 端口
EXPOSE 5678

# 創建 node 用戶並切換
RUN useradd -ms /bin/sh node && chown -R node:node /root/.n8n
USER node

# 使用 n8n 的啟動命令
CMD ["n8n", "start"]
