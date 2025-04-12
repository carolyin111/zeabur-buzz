FROM n8nio/n8n:1.86.1

USER root

# 安裝系統依賴 (使用 Alpine 的 apk 而非 apt-get)
RUN apk update && apk add --no-cache \
    ffmpeg \
    python3 \
    py3-pip \
    git \
    wget \
    build-base \
    python3-dev \
    linux-headers

# 安裝 Python 依賴
RUN pip3 install --no-cache-dir torch torchaudio openai-whisper

# 下載 Whisper 模型
RUN python3 -c "import whisper; whisper.load_model('small')"

# 設置工作目錄
WORKDIR /root/.n8n

# 配置環境變數
ENV DB_TYPE=postgresdb \
    GENERIC_TIMEZONE=Asia/Taipei \
    N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true \
    N8N_DIAGNOSTICS_ENABLED=false \
    N8N_RUNNERS_ENABLED=true \
    NODE_ENV=production

# 暴露n8n端口
EXPOSE 5678

# 使用n8n用戶運行
USER node

# 啟動n8n
CMD ["n8n", "start"]
