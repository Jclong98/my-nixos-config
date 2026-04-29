# My NixOS Configuration

NixOS flake configuration for **guillermo** — a KDE Plasma 6 desktop
running in the `America/Phoenix` timezone.

## Quick Start

Activate your changes:

```sh
sudo nixos-rebuild switch --flake .#guillermo
```

## Updating packages

Running the following command will update the `flake.lock`.

```sh
nix flake update
```

## LLM (llama-swap)

The LLM inference stack is managed declaratively via `modules/llama-swap.nix`.
Models are served through the **llama-swap** service on port **8080** (API)
and **3333** (direct llama-server fallback).

### Test llama-swap

```sh
curl -s http://192.168.0.3:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3.6-35b-a3b","messages":[{"role":"user","content":"say hi"}],"max_tokens":30}'
```

### Run a model manually (for testing)

```sh
llama-server --host 0.0.0.0 --port 3333 -hf unsloth/Qwen3.6-35B-A3B-GGUF:Q4_K_M
```

### List cached models

```sh
llama-server -cl
```

## Adding a New Model

Models are stored on disk at `/var/lib/llama-swap/models/` and declared in
`modules/llama-swap.nix` under `services.llama-swap.settings.models`.

### Step 1 — Place the model files on disk

Copy your `.gguf` file(s) into a directory under
`/var/lib/llama-swap/models/`.

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

### Step 2 — Declare the model in Nix

Add an entry to `services.llama-swap.settings.models` in `modules/llama-swap.nix`.

**Text-only model example:**

```nix
"my-model-id" = {
  cmd = "${llama-server} --port \${PORT} -m ${modelPath}/my-model/my-model-Q4_K_M.gguf";
  name = "My Model";
  description = "Short description of the model";
  ttl = 3600;
};
```

**Multimodal model example** (add `--mmproj` for vision support):

```nix
"my-vision-model" = {
  cmd = "${llama-server} --port \${PORT} -m ${modelPath}/my-model/model.gguf --mmproj ${modelPath}/my-model/mmproj-BF16.gguf";
  name = "My Vision Model";
  description = "Vision-capable model, Q4 quantized";
  ttl = 3600;
};
```

### Step 3 — Rebuild

```sh
sudo nixos-rebuild switch --flake ~/my-nixos-config#guillermo
```

The new model will now appear in llama-swap's model list and be available at the OpenAI-compatible API endpoint.

```sh
curl http://localhost:8080/v1/models
```