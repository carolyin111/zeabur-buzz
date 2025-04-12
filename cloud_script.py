import sys
import os
import subprocess
import math
from faster_whisper import WhisperModel
from pathlib import Path

def convert_to_wav(input_file, output_wav):
    """使用 FFmpeg 將輸入檔案轉為 WAV 格式（單聲道，16kHz）"""
    command = [
        "ffmpeg",
        "-i", input_file,
        "-ar", "16000",
        "-ac", "1",
        "-c:a", "pcm_s16le",
        output_wav
    ]
    try:
        subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        print(f"轉檔完成：{output_wav}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"FFmpeg 錯誤：{e.stderr}")
        return False

def split_audio(input_wav, output_dir, segment_length=600):
    """將 WAV 檔案分割成指定長度（秒）的片段"""
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # 獲取音頻時長
    command = ["ffprobe", "-i", input_wav, "-show_entries", "format=duration", "-v", "quiet", "-of", "csv=p=0"]
    duration = float(subprocess.check_output(command).decode().strip())

    # 計算片段數量
    num_segments = math.ceil(duration / segment_length)
    segment_files = []

    for i in range(num_segments):
        start_time = i * segment_length
        output_segment = os.path.join(output_dir, f"segment_{i:03d}.wav")
        command = [
            "ffmpeg",
            "-i", input_wav,
            "-ss", str(start_time),
            "-t", str(segment_length),
            "-c", "copy",
            output_segment
        ]
        try:
            subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            segment_files.append(output_segment)
            print(f"生成片段：{output_segment}")
        except subprocess.CalledProcessError as e:
            print(f"分割錯誤：{e.stderr}")

    return segment_files

def transcribe_segments(segment_files, model_name="medium"):
    """使用 faster-whisper 轉錄音頻片段"""
    model = WhisperModel(model_name, device="cpu", compute_type="int8")  # 可改為 GPU 若有支援
    transcripts = []

    for segment in segment_files:
        try:
            segments, info = model.transcribe(segment, beam_size=5)
            print(f"轉錄 {segment}，檢測語言：{info.language}")
            for seg in segments:
                transcripts.append({
                    "start": seg.start,
                    "end": seg.end,
                    "text": seg.text
                })
        except Exception as e:
            print(f"轉錄錯誤 {segment}：{str(e)}")

    return transcripts

def main():
    if len(sys.argv) < 2:
        print("請提供檔案路徑")
        sys.exit(1)

    # 從 n8n 接收檔案路徑
    file_path = sys.argv[1]  # 例如 "/root/.n8n/uploads/video.mp4"
    file_type = os.path.splitext(file_path)[1]  # 例如 ".mp4"
    base_path = os.path.splitext(file_path)[0]  # 例如 "/root/.n8n/uploads/video"

    # 步驟 1：轉檔到 WAV
    output_wav = f"{base_path}.wav"
    if not os.path.exists(file_path):
        print(f"檔案不存在：{file_path}")
        sys.exit(1)

    if not convert_to_wav(file_path, output_wav):
        sys.exit(1)

    # 步驟 2：分割音頻
    output_dir = f"{base_path}_segments"
    segment_files = split_audio(output_wav, output_dir, segment_length=600)  # 每段 10 分鐘

    # 步驟 3：轉錄逐字稿
    transcripts = transcribe_segments(segment_files, model_name="medium")

    # 輸出結果（可被 n8n 捕獲）
    print(json.dumps({
        "status": "success",
        "transcripts": transcripts,
        "wav_file": output_wav,
        "segment_files": segment_files
    }))

if __name__ == "__main__":
    main()
