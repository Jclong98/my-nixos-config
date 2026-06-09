{
  config,
  pkgs,
  lib,
  ...
}:

let
  # https://www.return12.net/building-latest-llama-cpp-on-nixos/
  # https://github.com/ggml-org/llama.cpp/releases
  llama-cpp = pkgs.llama-cpp-vulkan.overrideAttrs(attrs: rec {
    version = "9585";
    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b${version}";

      # when building, it'll be like "specified this but expected this"
      # just copy the expected hash from the error message and put it here.
      hash = "sha256-XJiCdPy6P+g70EM/o4EPJL2WUUEyroAsZO0hDNslx5Y=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };

    npmRoot = "tools/ui";
    # same here, just copy the expected hash from the error message when building.
    npmDepsHash = "sha256-pjdbI6NcZRlJVd62xhgbLhWrwFYwgsIwjORqvo1+VD8=";
  });
  llama-server = lib.getExe' llama-cpp "llama-server";
  modelPath = "/var/lib/llama-swap/models";
in
{
  # add llama-cpp to the system packages.
  # this will be merged and *should* use the version from the overrideAttrs above.
  environment.systemPackages = [ llama-cpp ];

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
          name = "Qwen3.6 35B A3B";
          description = "Unsloth Qwen3.6 35B A3B MTP, Q4_K_XL quantized, multimodal";
          ttl = 3600;
          cmd = "${llama-server} 
            --port \${PORT} 
            -m ${modelPath}/Qwen3.6-35B-A3B-MTP/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf 
            --mmproj ${modelPath}/Qwen3.6-35B-A3B-MTP/mmproj-BF16.gguf 
            --temp 0.6 
            --top-p 0.95 
            --top-k 20 
            --min-p 0.0 
            --presence-penalty 0.0 
            --repeat-penalty 1.0
            -fa on
            -np 1
            --spec-default
            --spec-draft-n-max 6
            --spec-type draft-mtp";
        };

        "qwen3.6-27b" = {
          name = "Qwen3.6 27B mtp 6";
          description = "Unsloth Qwen3.6 27B MTP, Q4_K_XL quantized, multimodal";
          ttl = 3600;
          cmd = "${llama-server} 
            --port \${PORT} 
            -m ${modelPath}/Qwen3.6-27B-MTP/Qwen3.6-27B-UD-Q4_K_XL.gguf 
            --mmproj ${modelPath}/Qwen3.6-27B-MTP/mmproj-BF16.gguf 
            --temp 0.6 
            --top-p 0.95 
            --top-k 20 
            --min-p 0.0 
            --presence-penalty 0.0 
            --repeat-penalty 1.0
            -fa on
            -np 1
            --spec-default
            --spec-draft-n-max 6
            --spec-type draft-mtp";
        };

        "gemma-4-31b" = {
          name = "Gemma 4 31B";
          description = "Unsloth Gemma 4 31B IT-QAT, Q4_K_XL quantized, multimodal";
          ttl = 3600;
          cmd = "${llama-server} 
            --port \${PORT} 
            -m ${modelPath}/gemma-4-31B-it-qat/gemma-4-31B-it-qat-UD-Q4_K_XL.gguf 
            --temp 1.0 
            --top-p 0.95 
            --top-k 64";
        };

        "gemma-4-26B-A4B" = {
          name = "Gemma 4 26B A4B";
          description = "Unsloth Gemma 4 26B A4B IT-QAT, Q4_K_XL quantized, multimodal";
          ttl = 3600;
          cmd = "${llama-server} 
            --port \${PORT} 
            -m ${modelPath}/gemma-4-26B-A4B-it-qat/gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf 
            --temp 1.0 
            --top-p 0.95 
            --top-k 64";
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
