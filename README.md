# My NixOS Configuration

NixOS flake configuration for **guillermo** — a KDE Plasma 6 desktop
running in the `America/Phoenix` timezone.

## Quick Start

Activate your changes:

```sh
sudo nixos-rebuild switch --flake .#guillermo
```

## LLM

## run a model

```sh
llama-server --host 0.0.0.0 --port 3333 -hf unsloth/Qwen3.6-35B-A3B-GGUF:Q4_K_M
```

## list cached models

```sh
llama-server -cl
```

## test llama-swap

```sh
curl -s http://192.168.0.3:8080/v1/chat/completions -H 'Content-Type: application/json' -d '{"model":"qwen3-35b-a3b","messages":[{"role":"user","content":"say hi"}],"max_tokens":30}'
```