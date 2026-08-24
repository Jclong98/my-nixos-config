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
  # This module lives in nixos/modules/vllm/, next to docker-compose.yml.
  vllmDir = ./.;
  compose = lib.getExe pkgs.docker-compose;
in
{
  options.services.vllm.enable = lib.mkEnableOption "vLLM OpenAI server (docker container)";

  config = lib.mkIf config.services.vllm.enable {
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
        WorkingDirectory = vllmDir;

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
