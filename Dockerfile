FROM n8nio/n8n:1.86.1

USER root

# 安裝基本依賴
RUN apk update && apk add --no-cache \
    ffmpeg \
    python3 \
    py3-pip \
    git \
    wget \
    build-base \
    python3-dev \
    linux-headers

# 為了避免系統 Python 問題，使用較簡單的 whisper 實現
RUN pip3 install --no-cache-dir --break-system-packages \
    numpy \
    setuptools-rust \
    https://github.com/guillaumekln/faster-whisper/archive/refs/heads/master.zip

# 設置工作目錄
WORKDIR /root/.n8n

# 原有的環境變數保持不變
ENV DB_TYPE=postgresdb \
    GENERIC_TIMEZONE=Asia/Taipei \
    N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true \
    N8N_DIAGNOSTICS_ENABLED=false \
    N8N_RUNNERS_ENABLED=true \
    NODE_ENV=production

# 暴露n8n端口
EXPOSE 5678

# 切換回n8n用戶
USER node

# 使用原始的啟動命令
CMD ["n8n", "start"]
