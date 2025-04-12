# 第一階段：使用官方 Python 3.9 映像
FROM python:3.9-slim AS base

# 安裝系統依賴
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 建立虛擬環境
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 安裝 PyTorch 和 Whisper
RUN pip install --upgrade pip && \
    pip install torch==1.10.1 && \
    pip install git+https://github.com/openai/whisper.git

# 第二階段：使用 n8n 官方映像
FROM n8nio/n8n:1.86.1

USER root

# 從 Python 映像複製已安裝的工具和依賴
COPY --from=base /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=base /usr/bin/ffprobe /usr/bin/ffprobe
COPY --from=base /opt/venv /opt/venv
COPY --from=base /usr/local/bin/python /usr/bin/python3
COPY --from=base /usr/local/lib/python3.9 /usr/local/lib/python3.9
COPY --from=base /usr/local/lib/libpython3.9.so.1.0 /usr/local/lib/libpython3.9.so.1.0

# 安裝 Git
RUN apk add --no-cache git

# 設定環境變數
ENV PATH="/opt/venv/bin:$PATH" \
    LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
    PYTHONPATH="/opt/venv/lib/python3.9/site-packages:$PYTHONPATH" \
    DB_TYPE=postgresdb \
    GENERIC_TIMEZONE=Asia/Taipei \
    N8N_COMMUNITY_PACKAGES_ALLOW_TOOL_USAGE=true \
    N8N_DIAGNOSTICS_ENABLED=false \
    N8N_RUNNERS_ENABLED=true \
    NODE_ENV=production

# 暴露 n8n 端口
EXPOSE 5678

# 切換回 n8n 用戶
USER node

# 啟動 n8n
CMD ["n8n", "start"]
