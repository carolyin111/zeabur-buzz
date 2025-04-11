from fastapi import FastAPI, HTTPException
import os
import subprocess

app = FastAPI()

@app.get("/")
async def health_check():
    return {"status": "healthy"}

@app.post("/process")
async def process_file(file_path: str):
    """
    處理共享卷中的 MP4 檔案，轉為 MP3
    輸入：file_path（例如 /data/input/meeting.mp4）
    輸出：MP3 檔案（例如 /data/output/meeting.mp3）
    """
    if not os.path.exists(file_path):
        raise HTTPException(status_code=400, detail="File not found")

    # 確保輸出目錄存在
    output_dir = "/data/output"
    os.makedirs(output_dir, exist_ok=True)

    # 設定輸出路徑
    output_path = os.path.join(output_dir, os.path.basename(file_path).replace(".mp4", ".mp3"))

    # 使用 FFmpeg 轉換
    try:
        subprocess.run([
            "ffmpeg", "-i", file_path, "-vn", "-acodec", "mp3", "-b:a", "128k", output_path
        ], check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"FFmpeg error: {e.stderr}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

    return {
        "message": "Processing complete",
        "input": file_path,
        "output": output_path
    }
