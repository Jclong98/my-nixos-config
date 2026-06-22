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

  # llama-server in router mode
  systemd.services.llama-server = {
    description = "llama.cpp server (router mode)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.escapeShellArgs [
        (lib.getExe' llama-cpp "llama-server")
        "--models-dir" modelPath
        "--host" "0.0.0.0"
        "--port" "8080"
        "--models-max" "1"
      ];
      Restart = "on-failure";
      # DynamicUser + ProtectHome blocks access to ~/.cache.
      # HOME=/tmp gives llama-server a writable path for Vulkan shader cache.
      Environment = [ "HOME=/tmp" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
