# vLLM OpenAI server via docker compose.
#
# The compose file and the ~20GB models/ cache (gitignored) live in this
# directory, so the unit runs as the guillermo user from here. The
# container is owned by docker; this unit only drives `docker compose
# up -d --wait` on start and `down` on stop.

{
  config,
  pkgs,
  lib,
  ...
}:

let
  compose = lib.getExe pkgs.docker-compose;
in
{
  options.services.vllm.enable = lib.mkEnableOption "vLLM OpenAI server (docker container)";

  # Must be the on-disk checkout, NOT the store copy: `./` in a module
  # resolves to /nix/store/...-source/, and the gitignored models/ cache
  # does not exist there (and can't be created; the store is read-only).
  options.services.vllm.composeDir = lib.mkOption {
    type = lib.types.str;
    default = "/home/guillermo/my-nixos-config/nixos/modules/vllm";
    description = "Directory containing docker-compose.yml and the gitignored models/ cache.";
  };

  config = lib.mkIf config.services.vllm.enable {
    assertions = [
      {
        assertion = builtins.pathExists "${config.services.vllm.composeDir}/models";
        message = "services.vllm.composeDir is missing the gitignored models/ directory (got ${config.services.vllm.composeDir})";
      }
    ];

    systemd.services.vllm = {
      description = "vLLM OpenAI server (docker container)";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "docker.service" "network-online.target" ];
      requires = [ "docker.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "guillermo";
        WorkingDirectory = config.services.vllm.composeDir;

        # `up -d --wait` blocks until the /health probe passes; loading
        # the 20GB model can take several minutes.
        TimeoutStartSec = 600;

        ExecStart = lib.escapeShellArgs [
          compose
          "up"
          "-d"
          "--wait"
        ];
        ExecStop = lib.escapeShellArgs [
          compose
          "down"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 8000 ];
  };
}
