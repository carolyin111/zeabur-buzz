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

# 安裝 Python 依賴
RUN pip3 install --no-cache-dir --break-system-packages \
    numpy \
    setuptools-rust \
    https://github.com/guillaumekln/faster-whisper/archive/refs/heads/master.zip

# 設置工作目錄
WORKDIR /root/.n8n

# 設置環境變數，與 YAML 配置一致
ENV DB_TYPE=postgresdb \
    DB_POSTGRESDB_DATABASE=${POSTGRES_DATABASE} \
    DB_POSTGRESDB_HOST=${POSTGRES_HOST} \
    DB_POSTGRESDB_PORT=${POSTGRES_PORT} \
    DB_POSTGRESDB_USER=${POSTGRES_USERNAME} \
    DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD} \
    GENERIC_TIMEZONE=Asia/Taipei \
    N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true \
    N8N_DIAGNOSTICS_ENABLED=false \
    N8N_ENCRYPTION_KEY=${PASSWORD} \
    N8N_HOST=${ZEABUR_WEB_DOMAIN} \
    N8N_PORT=5678 \
    N8N_RUNNERS_ENABLED=true \
    NODE_ENV=production \
    WEBHOOK_URL=${ZEABUR_WEB_URL}

# 暴露 n8n 端口
EXPOSE 5678

# 切換回 node 用戶
USER node

# 使用原始的啟動命令
CMD ["n8n", "start"]
