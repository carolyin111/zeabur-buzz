FROM python:3.10-slim

# 安裝系統依賴
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

# 更新 pip 到最新版本
RUN pip install --no-cache-dir --upgrade pip

# 安裝 Python 依賴
RUN pip install --no-cache-dir \
    fastapi==0.115.0 \
    uvicorn==0.30.6

# 設定工作目錄
WORKDIR /app

# 複製 FastAPI 應用程式
COPY app.py /app/app.py

# 暴露端口
EXPOSE 8000

# 啟動 FastAPI
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
