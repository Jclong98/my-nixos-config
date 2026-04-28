{ config, pkgs, lib, ... }:

let
  llama-cpp = pkgs.llama-cpp-vulkan;
  llama-server = lib.getExe' llama-cpp "llama-server";
in
{
  services.llama-swap = {
    enable = true;
    openFirewall = true;
    listenAddress = "0.0.0.0";

    settings = {
      models = {
        "qwen3-35b-a3b" = {
          cmd = "${llama-server} --port \${PORT} -hf unsloth/Qwen3.6-35B-A3B-GGUF:Q4_K_M";
          name = "Qwen3.6 35B A3B";
          description = "Unsloth Qwen3.6 35B A3B, Q4 quantized";
          ttl = 3600;
        };
      };
    };
  };
}
