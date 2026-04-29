{ config, pkgs, lib, ... }:

let
  llama-cpp = pkgs.llama-cpp-vulkan;
  llama-server = lib.getExe' llama-cpp "llama-server";
  modelPath = "/var/lib/llama-swap/models/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf";
in
{
  services.llama-swap = {
    enable = true;
    openFirewall = true;
    listenAddress = "0.0.0.0";

    settings = {
      macros ={
        default_ctx = 128000;
      };

      models = {
        "qwen3-35b-a3b" = {
          cmd = "${llama-server} --port \${PORT} -m ${modelPath}";
          name = "Qwen3.6 35B A3B";
          description = "Unsloth Qwen3.6 35B A3B, Q4 quantized";
          ttl = 3600;
        };
      };
    };
  };

  # DynamicUser + ProtectHome blocks access to ~/.cache.
  # HOME=/tmp gives llama-server a writable path for Vulkan shader cache.
  systemd.services.llama-swap.serviceConfig.Environment = [ "HOME=/tmp" ];
}
