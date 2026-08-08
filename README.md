# My NixOS Configuration

NixOS flake configuration for **guillermo** — a KDE Plasma 6 desktop
running in the `America/Phoenix` timezone.

## Quick Start

Activate your changes:

```sh
sudo nixos-rebuild switch --flake .#guillermo
```

### Updating packages

Running the following command will update the `flake.lock`.

```sh
nix flake update
```

You can rebuild and upgrade at the same time

```sh
sudo nixos-rebuild switch --flake .#guillermo --upgrade
```

### Deleting old packages

```sh
nix-collect-garbage -d
```

## LLM (llama-server)

The LLM inference stack is managed declaratively via `modules/llama.nix`.
Models are served through **llama-server** running in router mode on port **8080**.
The router automatically discovers models placed in `/var/lib/llama-swap/models/`.

### Test llama-server

```sh
curl -s http://192.168.0.3:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3.6-35b-a3b","messages":[{"role":"user","content":"say hi"}],"max_tokens":30}'
```

### List available models

```sh
curl http://localhost:8080/v1/models
```

### Run a model manually (for testing)

```sh
llama-server --host 0.0.0.0 --port 3333 -hf unsloth/Qwen3.6-35B-A3B-GGUF:Q4_K_M
```

## Adding a New Model

Models are stored on disk at `/var/lib/llama-swap/models/`. llama-server's
router mode automatically discovers any model placed there — no Nix config
changes are needed.

### Place the model files on disk

Copy your `.gguf` file(s) into a directory under `/var/lib/llama-swap/models/`.

**Text-only model:**

```
/var/lib/llama-swap/models/
└── my-model/
    └── my-model-Q4_K_M.gguf
```

**Multimodal model** (requires a projection file too):

```
/var/lib/llama-swap/models/
└── my-model/
    ├── my-model-Q4_K_M.gguf
    └── mmproj-BF16.gguf
```

> **Tip:** Download GGUF files from [HuggingFace](https://huggingface.co) using
> `llama-server -hf <repo>:<tag>` or with the `huggingface-cli` tool.

### Restart the service

```sh
sudo systemctl restart llama-server
```

Or rebuild if you changed `modules/llama.nix`:

```sh
sudo nixos-rebuild switch --flake ~/my-nixos-config#guillermo
```

The new model will now appear in llama-server's model list and be available at the OpenAI-compatible API endpoint:

```sh
curl http://localhost:8080/v1/models
```

### Running a text to speech model

`--tts-lang` can be `zh`, `en`, `de`, `it`, `pt`, `es`, `ja`, `ko`, `fr`, `ru` (default: `en`)

```sh
llama-tts -hf ggml-org/Qwen3-TTS-12Hz-1.7B-Base-GGUF -p "test speech" --tts-lang en --tts-speaker-file ./tts/reference.mp3 --output ./tts/out.wav
```