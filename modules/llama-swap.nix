{
  config,
  pkgs,
  lib,
  ...
}:

let
  llama-cpp = pkgs.llama-cpp-vulkan;
  llama-server = lib.getExe' llama-cpp "llama-server";
  modelPath = "/var/lib/llama-swap/models";
in
{
  services.llama-swap = {
    enable = true;
    openFirewall = true;
    listenAddress = "0.0.0.0";
    port = 8080;

    settings = {
      macros = {
        default_ctx = 128000;
      };

      models = {
        # extra flags are recommended by https://huggingface.co/Qwen/Qwen3.6-27B
        "qwen3.6-35b-a3b" = {
          cmd = "${llama-server} --port \${PORT} -m ${modelPath}/Qwen3.6-35B-A3B/Qwen3.6-35B-A3B-UD-Q4_K_M.gguf --mmproj ${modelPath}/Qwen3.6-35B-A3B/mmproj-BF16.gguf --temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.0 --presence-penalty 0.0 --repeat-penalty 1.0";
          name = "Qwen3.6 35B A3B";
          description = "Unsloth Qwen3.6 35B A3B, Q4 quantized";
          ttl = 3600;
        };

        "qwen3.6-27b" = {
          cmd = "${llama-server} --port \${PORT} -m ${modelPath}/Qwen3.6-27B/Qwen3.6-27B-Q4_K_M.gguf --mmproj ${modelPath}/Qwen3.6-27B/mmproj-BF16.gguf --temp 0.6 --top-p 0.95 --top-k 20 --min-p 0.0 --presence-penalty 0.0 --repeat-penalty 1.0";
          name = "Qwen3.6 27B";
          description = "Unsloth Qwen3.6 27B, Q4 quantized";
          ttl = 3600;
        };

        "gemma-4-31b-it" = {
          cmd = "${llama-server} --port \${PORT} -m ${modelPath}/gemma-4-31B-it/gemma-4-31B-it-Q4_K_M.gguf --mmproj ${modelPath}/gemma-4-31B-it/mmproj-BF16.gguf --temp 1.0 --top-p 0.95 --top-k 64a";
          name = "Gemma 4 31B IT";
          description = "Unsloth Gemma 4 31B Instruction-Tuned, Q4 quantized, multimodal";
          ttl = 3600;
        };

        "gemma-4-e4b-it" = {
          cmd = "${llama-server} --port \${PORT} -m ${modelPath}/gemma-4-E4B-it/gemma-4-E4B-it-Q4_K_M.gguf --mmproj ${modelPath}/gemma-4-E4B-it/mmproj-BF16.gguf --temp 1.0 --top-p 0.95 --top-k 64a";
          name = "Gemma 4 E4B IT";
          description = "Unsloth Gemma 4 E4B Instruction-Tuned, Q4 quantized, multimodal";
          ttl = 3600;
        };
      };
    };
  };

  # DynamicUser + ProtectHome blocks access to ~/.cache.
  # HOME=/tmp gives llama-server a writable path for Vulkan shader cache.
  systemd.services.llama-swap.serviceConfig.Environment = [ "HOME=/tmp" ];

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8081;
    openFirewall = true;

    environment = {
      ENABLE_OPENAI_API = "True";
      OPENAI_API_BASE_URL = "http://127.0.0.1:8080/v1";
      OPENAI_API_KEY = "fake-key";
    };
  };
}
