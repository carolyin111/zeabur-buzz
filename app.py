from fastapi import FastAPI, HTTPException
from buzz import transcribe
import os

app = FastAPI()

@app.get("/")
async def health_check():
    return {"status": "healthy"}

@app.post("/transcribe")
async def transcribe_audio(file_path: str):
    if not os.path.exists(file_path):
        raise HTTPException(status_code=400, detail="File not found")

    audio_path = file_path.replace(".mp4", ".mp3")
    try:
        os.system(f"ffmpeg -i {file_path} -vn -acodec mp3 -b:a 128k {audio_path}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"FFmpeg error: {str(e)}")

    try:
        result = transcribe(
            file_path=audio_path,
            model_type="whispercpp",
            model_size="small",
            language="zh",
            task="transcribe",
            srt=True,
            vtt=True
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Transcribe error: {str(e)}")

    transcript = result["text"]
    srt_path = audio_path.replace(".mp3", ".srt")
    vtt_path = audio_path.replace(".mp3", ".vtt")

    with open(srt_path, "r", encoding="utf-8") as f:
        srt_content = f.read()
    with open(vtt_path, "r", encoding="utf-8") as f:
        vtt_content = f.read()

    for path in [audio_path, srt_path, vtt_path]:
        if os.path.exists(path):
            os.remove(path)

    return {
        "transcript": transcript,
        "srt": srt_content,
        "vtt": vtt_content
    }
