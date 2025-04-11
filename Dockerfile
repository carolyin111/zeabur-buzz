FROM python:3.10-slim

# 安裝系統依賴
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ffmpeg \
    libportaudio2 \
    && rm -rf /var/lib/apt/lists/*

# 更新 pip 到最新版本
RUN pip install --no-cache-dir --upgrade pip

# 設定工作目錄
WORKDIR /app

# 安裝 Python 依賴
RUN pip install --no-cache-dir \
    buzz-captions==1.2.0 \
    fastapi==0.115.0 \
    uvicorn==0.30.6

# 下載並編譯 Whisper.cpp
RUN git clone --depth 1 https://github.com/ggerganov/whisper.cpp.git /whisper.cpp
WORKDIR /whisper.cpp
RUN make
RUN ./models/download-ggml-model.sh small

# 設定模型儲存路徑
ENV BUZZ_MODEL_ROOT=/data/models

# 複製 API 程式碼
COPY app.py /app/app.py

# 返回工作目錄
WORKDIR /app

# 暴露端口
EXPOSE 8000

# 健康檢查
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# 啟動 FastAPI
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
