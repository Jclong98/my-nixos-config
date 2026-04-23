{ config, pkgs, ... }:

{
  # Local LLM related services
  services.ollama = {
    enable = true;
    openFirewall = true;

    loadModels = [
      "gemma4:e2b"
      "qwen3.6:35b-a3b-q4_K_M"
      "qwen3.6:27b-coding-mxfp8"
    ];

    package = pkgs.ollama-vulkan;
  };

  # open-webui (port 8080 by default)
  services.open-webui = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
  };
}
