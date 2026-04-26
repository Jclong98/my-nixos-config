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
llama-server --host 0.0.0.0 --port 8080 -hf unsloth/Qwen3.6-35B-A3B-GGUF:Q4_K_M
```

## list cached models

```sh
llama-server -cl
```