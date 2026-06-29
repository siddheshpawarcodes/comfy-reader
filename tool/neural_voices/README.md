# Neural voices (Phase 3) — convert & side-load

Phase 1/2 use the OS TTS engine. That works for Hindi/English but on most devices
has **no usable Marathi (or other Indic) voice** — the engine then spells out
matras, and our fallback reads Marathi with a Hindi accent. Phase 3 ships a real,
on-device **neural** Marathi voice via [`sherpa_onnx`](https://pub.dev/packages/sherpa_onnx)
running an **AI4Bharat `vits_rasa_13`** model (CC-BY-4.0 — commercial use allowed,
attribution required).

`vits_rasa_13` has **no official ONNX build**, so it must be converted once, then
hosted for in-app download. This folder is the recipe. The conversion needs a
Python/ML environment (not the Flutter toolchain).

## 0. Check for a pre-converted model first
Before converting, check whether a sherpa-onnx-ready build already exists — it
saves all of the work below:
- k2-fsa releases: https://github.com/k2-fsa/sherpa-onnx/releases (TTS models)
- `csukuangfj` on Hugging Face (many `vits-*` ONNX TTS models)

A sherpa-onnx VITS voice is a directory containing at least:
```
model.onnx        # the exported VITS model
tokens.txt        # token → id table the model was trained with
# plus ONE frontend, depending on how the model does grapheme→phoneme:
lexicon.txt       # word → tokens   (lexicon frontend), OR
espeak-ng-data/   # dataDir         (espeak frontend), OR
dict/             # dictDir         (jieba etc. — not needed for Indic)
```
If you find one for Marathi that is commercially licensed, skip to **§3 (side-load)**.

## 1. Export `vits_rasa_13` → ONNX
Model card: https://huggingface.co/ai4bharat/vits_rasa_13 (verify the license and
the **training-data** terms before shipping a paid app).

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install torch onnx onnxruntime numpy
# plus AI4Bharat's inference deps (see the model card / its repo)
python export_vits_rasa.py --lang mr --out build/mr
```
`export_vits_rasa.py` in this folder is a **skeleton** — the trace/forward call is
model-specific and marked with TODOs. It must emit `model.onnx` + `tokens.txt`
(and the matching frontend files) into `build/<lang>`.

## 2. Verify on desktop before shipping
```bash
pip install sherpa-onnx soundfile
python - <<'PY'
import sherpa_onnx, soundfile as sf
tts = sherpa_onnx.OfflineTts(sherpa_onnx.OfflineTtsConfig(
    model=sherpa_onnx.OfflineTtsModelConfig(
        vits=sherpa_onnx.OfflineTtsVitsModelConfig(
            model="build/mr/model.onnx", tokens="build/mr/tokens.txt",
            # lexicon="build/mr/lexicon.txt" OR data_dir="build/mr/espeak-ng-data"
        ), num_threads=2)))
audio = tts.generate("नमस्कार, हा वाचनाचा एक नमुना आहे.", sid=0, speed=1.0)
sf.write("out.wav", audio.samples, audio.sample_rate)
print("ok", audio.sample_rate, len(audio.samples))
PY
```
Listen to `out.wav`. If the Marathi sounds right here, it will sound the same in
the app (sherpa-onnx is the same engine on device).

## 3. Side-load for on-device testing (no download infra needed yet)
The app looks for a side-loaded voice in its support dir, under
`neural_voices/<id>/` (see `NeuralVoiceCatalog` in
`lib/services/neural_tts_service.dart` for the exact `id`, e.g. `ai4bharat-mr`).

Push the converted folder to the **running app's** files dir:
```bash
# find the app's support dir id is com.example.comfy_reader
adb shell run-as com.example.comfy_reader mkdir -p files/neural_voices/ai4bharat-mr
adb push build/mr/. /sdcard/Download/ai4bharat-mr/
# then copy into the sandbox (run-as can't read /sdcard directly on all devices):
adb shell run-as com.example.comfy_reader sh -c 'cp -r /sdcard/Download/ai4bharat-mr/* files/neural_voices/ai4bharat-mr/'
```
Open **Settings → Read-aloud voices → Marathi** — when the model files are
present, the row shows a "Natural voice" tag and the ▶ preview plays the neural
voice. (The exact support-dir path is logged at startup; `getApplicationSupportDirectory()`.)

## 4. Hosting (for the in-app download — next slice)
Once a voice sounds good: tar/zip the `<id>` folder, host it (GitHub Release asset
or your bucket), and put the URL + size + sha256 into `NeuralVoiceCatalog`. The
download manager (next slice) fetches + extracts into the same
`neural_voices/<id>/` layout the side-load uses.

## Attribution (required by CC-BY-4.0)
Ship an attribution line for every AI4Bharat voice in the app's licenses screen,
e.g. *"Marathi voice: AI4Bharat vits_rasa_13, CC-BY-4.0."*
