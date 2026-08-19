{
  config,
  pkgs,
  lib,
  ...
}:

let
  # https://www.return12.net/building-latest-llama-cpp-on-nixos/
  # https://github.com/ggml-org/llama.cpp/releases
  llama-cpp = pkgs.llama-cpp-vulkan.overrideAttrs (attrs: rec {
    version = "10413";
    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b${version}";

      # when building, it'll be like "specified this but expected this"
      # just copy the expected hash from the error message and put it here.
      hash = "sha256-hN8WCXS/G1jtiSHop9+iUytZPLZxRDZ5fG8S1IHTndo=";
      leaveDotGit = true;
      postFetch = ''
        git -C "$out" rev-parse --short HEAD > $out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
      '';
    };

    # same here, just copy the expected hash from the error message when building.
    npmDepsHash = "sha256-2Q7XhaLAArmviOLdQsNbYTfdyDE5pW9lR26cRHEVl9k=";
  });
  llama-server = lib.getExe' llama-cpp "llama-server";
  modelPath = "/var/lib/llama-server/models";
  # Per-model arguments (INI), versioned in the repo at nixos/modules/models.ini.
  # Written into the nix store (content-addressed): editing the file
  # changes the unit's ExecStart, so nixos-rebuild restarts the service.
  modelsPreset = pkgs.writeText "llama-models.ini" (builtins.readFile ./models.ini);
in
{
  # add llama-cpp to the system packages.
  # this is merged with modules/programs.nix and uses the build from the
  # overrideAttrs above.
  environment.systemPackages = [ llama-cpp ];

  # llama-server in router mode
  systemd.services.llama-server = {
    description = "llama.cpp server (router mode)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.escapeShellArgs [
        (lib.getExe' llama-cpp "llama-server")
        "--models-dir"
        modelPath
        "--models-preset"
        modelsPreset
        "--host"
        "0.0.0.0"
        "--port"
        "8080"
        "--models-max"
        "1"
      ];
      Restart = "on-failure";

      # Sandbox: models are read from /var/lib/llama-server, the only place
      # the server may write. ProtectHome keeps it out of user home dirs;
      # HOME=/tmp still gives it a writable dir for the Vulkan shader cache
      # (/tmp is a separate mount, so it stays writable under strict).
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ReadWritePaths = [ "/var/lib/llama-server" ];
      PrivateTmp = true;
      NoNewPrivileges = true;
      Environment = [ "HOME=/tmp" ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}
