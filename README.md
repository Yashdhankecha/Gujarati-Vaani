# ગુજરાતી વાણી (Gujarati Vaani)

A Flutter mobile app that converts Gujarati text into natural speech using a fine-tuned Meta MMS VITS model, served by a FastAPI backend on Hugging Face Spaces.

**Author:** Yash Dhankecha

---

## Overview

- Gujarati-only text input with language validation
- Converts Gujarati and Arabic numerals into spoken Gujarati words
- Handles long text by splitting it into small chunks
- Built-in audio player with seek, speed control (0.5x–2.0x), download, and share
- Retries automatically if the server is waking up

---

## How It Works

```
Flutter App → FastAPI Backend (Hugging Face Space) → Fine-tuned MMS-TTS → WAV Audio → App
```

1. User enters Gujarati text in the app.
2. The app checks the language and splits the text into ~250-character chunks.
3. Each chunk is sent to the backend with a speech speed value.
4. The backend converts numbers to Gujarati words and runs the fine-tuned VITS model.
5. The model returns 16 kHz WAV audio for each chunk.
6. The app merges the chunks with short silence gaps.
7. Audio plays automatically; the user can pause, seek, change speed, download, or share it.

---

## Tech Stack

**Mobile App**

| Technology | Purpose |
|------------|---------|
| Flutter 3.35+ / Dart 3.5+ | Mobile UI |
| `http` | Backend API calls |
| `audioplayers` | Audio playback |
| `path_provider` | Temporary audio files |
| `share_plus` | Sharing audio |
| `permission_handler` | Storage permission |

**Backend**

| Technology | Purpose |
|------------|---------|
| Python 3.10 | Runtime |
| FastAPI + Uvicorn | REST API |
| PyTorch 2.1 | Model inference |
| Transformers 4.36 | Model and tokenizer |
| Hugging Face Spaces (Docker) | Hosting |
| Hugging Face Hub | Fine-tuned model storage |

**Training**

- PyTorch, Transformers, Librosa, SoundFile, TensorBoard
- Azure ML `Standard_NC6` (Tesla T4 GPU)

---

## How It Is Made

1. **Prepare the dataset** — `training/prepare_dataset.py`
2. **Fine-tune the model** — `train.py`, `train_v2.py`, `train_curriculum.py`, or `train_multivoice.py`
3. **Verify the model** — `training/verify_tuned_model.py`
4. **Publish the model** — upload `original/` and `tokenizer/` files to the Hugging Face Hub repo set in `MODEL_REPO_ID`
5. **Deploy the backend** — upload `huggingface_space/` to a Docker Space
6. **Connect the app** — set `apiUrl` in `flutter_app/lib/services/tts_service.dart`
7. **Build the app** — `flutter build apk --release`
8. **Install and test** — install the APK on an Android phone

---

## Project Structure

```
Gujarati-Vaani/
├── flutter_app/                # Flutter mobile app
│   ├── lib/main.dart           # UI, validation, audio player
│   └── lib/services/tts_service.dart  # API calls, chunking, retries
├── huggingface_space/          # FastAPI backend for Hugging Face Spaces
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── training/                   # Dataset, training, and deployment scripts
│   └── TRAINING_GUIDE.md
└── README.md
```

---

## API

**Base URL:** `https://yashdhankecha-gujarati-vaani-tts.hf.space`

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Check server and model status |
| `POST` | `/synthesize` | Convert one text to WAV audio |
| `POST` | `/batch_synthesize` | Convert up to 100 texts (JSON with base64 audio) |

**Synthesize request**

```json
{
  "text": "નમસ્તે, કેમ છો?",
  "speed": 1.0
}
```

`speed` accepts values from `0.5` to `2.0`. The response is a `audio/wav` file.

---

## Run the App

```bash
git clone https://github.com/Yashdhankecha/Gujarati-Vaani.git
cd Gujarati-Vaani/flutter_app
flutter pub get
flutter run
```

To build an APK:

```bash
flutter build apk --release
```

The APK is created at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Model

| Property | Value |
|----------|-------|
| Base model | `facebook/mms-tts-guj` |
| Architecture | VITS (MMS-TTS) |
| Output | 16 kHz mono WAV |
| Size | ~275 MB |
| Hosting | Hugging Face Hub (`MODEL_REPO_ID`) |

The backend loads the model from local files first, then falls back to the Hugging Face Hub.

---

## Configuration

| Setting | Where |
|---------|-------|
| API URL | `flutter_app/lib/services/tts_service.dart` (`apiUrl`, overridable with `--dart-define=TTS_API_URL=...`) |
| Chunk size | `tts_service.dart` (`maxChunkSize`, default 250) |
| Model repo | `huggingface_space/app.py` (`MODEL_REPO_ID`) |
| Azure storage | `huggingface_space/app.py` (`AZURE_ACCOUNT`, `AZURE_CONTAINER`, `AZURE_SAS_TOKEN`) |

Environment variables are optional for the core app. Set `MODEL_REPO_ID` to point to your model repo, and set `AZURE_SAS_TOKEN` (plus the Azure account/container values) only if you use the optional Azure helper.

The Azure Blob download helper in `app.py` is optional and is not called automatically.

---

## Author

**Yash Dhankecha**
GitHub: [Yashdhankecha](https://github.com/Yashdhankecha)
Repository: [Gujarati-Vaani](https://github.com/Yashdhankecha/Gujarati-Vaani)

For questions or issues, please open an issue in the repository.

---

**Last Updated:** October 2026
