#!/usr/bin/env python3
"""Export AI4Bharat vits_rasa_13 to a sherpa-onnx VITS voice directory.

SKELETON — the model load + ONNX trace are model-specific and marked TODO. See
README.md (§1) for the surrounding workflow. The goal is to emit, into --out:

    model.onnx     the traced VITS graph (inputs: token ids; output: waveform)
    tokens.txt     "<symbol> <id>" per line, matching the model's symbol table
    lexicon.txt    word -> space-separated tokens   (if using a lexicon frontend)
      (or copy an espeak-ng-data/ dir instead, if using the espeak frontend)

Run:  python export_vits_rasa.py --lang mr --out build/mr
Verify the result with the sherpa-onnx Python snippet in README.md (§2).
"""
import argparse
import os


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--lang", required=True, help="ISO code, e.g. mr / hi / ta")
    ap.add_argument("--out", required=True, help="output directory")
    ap.add_argument("--model-id", default="ai4bharat/vits_rasa_13",
                    help="Hugging Face model id")
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)

    # 1) Load the model + its symbol table.
    #    TODO: load weights/config for args.model_id (see the model card repo).
    #    model, symbols, frontend = load_vits_rasa(args.model_id, args.lang)

    # 2) Write tokens.txt from the model's symbol table.
    #    with open(f"{args.out}/tokens.txt", "w", encoding="utf-8") as f:
    #        for sym, idx in symbols.items():
    #            f.write(f"{sym} {idx}\n")

    # 3) Trace to ONNX. Inputs are the token-id sequence (+ length, sid, scales,
    #    per the model's forward signature); output is the float waveform.
    #    torch.onnx.export(model, dummy_inputs, f"{args.out}/model.onnx",
    #                      input_names=[...], output_names=["audio"],
    #                      dynamic_axes={...}, opset_version=17)

    # 4) Emit the frontend the model expects (lexicon.txt OR espeak-ng-data/).
    #    AI4Bharat models normalize Indic text with their own G2P — replicate it
    #    as a lexicon, or wire the matching espeak-ng data, so on-device input
    #    matches training. This is the part most likely to need iteration.

    raise SystemExit(
        "export_vits_rasa.py is a skeleton: implement the TODOs above for "
        f"{args.model_id} ({args.lang}). See README.md."
    )


if __name__ == "__main__":
    main()
