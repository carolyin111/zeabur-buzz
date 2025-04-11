FROM python:3.10-slim
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ffmpeg \
    libportaudio2 \
    wget \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir --upgrade pip
WORKDIR /app
RUN pip install --no-cache-dir \
    buzz-captions==1.2.0 \
    fastapi==0.115.0 \
    uvicorn==0.30.6
RUN git clone --depth 1 https://github.com/ggerganov/whisper.cpp.git /whisper.cpp
WORKDIR /whisper.cpp
RUN make
RUN ./models/download-ggml-model.sh small
ENV BUZZ_MODEL_ROOT=/data/models
COPY app.py /app/app.py
WORKDIR /app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
