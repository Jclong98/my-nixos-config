{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.llm-rgb;

  monitorScript = pkgs.writeShellApplication {
    name = "llm-rgb-monitor";
    runtimeInputs = with pkgs; [ openrgb-with-all-plugins iproute2 ];

    text = ''
      ACTIVE_COLOR="${cfg.activeColor}"
      IDLE_COLOR="${cfg.idleColor}"
      PORT="${toString cfg.port}"
      TIMEOUT="${toString cfg.timeoutSeconds}"
      INTERVAL="${toString cfg.pollIntervalSeconds}"

      last_active=0
      state=0

      set_color() {
        openrgb -c "$1"
      }

      # Set initial idle color
      set_color "$IDLE_COLOR"

      while true; do
        if ss -tn sport = :"$PORT" | grep -q ESTAB; then
          last_active=$(date +%s)
          if [ "$state" != "1" ]; then
            set_color "$ACTIVE_COLOR"
            state=1
          fi
        else
          now=$(date +%s)
          elapsed=$(( now - last_active ))
          if [ "$elapsed" -gt "$TIMEOUT" ] && [ "$state" = "1" ]; then
            set_color "$IDLE_COLOR"
            state=0
          fi
        fi
        sleep "$INTERVAL"
      done
    '';
  };
in
{
  options.services.llm-rgb = {
    enable = lib.mkEnableOption "LLM RGB monitor — changes fan color when the LLM is responding";

    port = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Port to monitor for LLM traffic";
    };

    activeColor = lib.mkOption {
      type = lib.types.str;
      default = "FF0000";
      description = "Hex color (RRGGBB) when the LLM is actively responding";
    };

    idleColor = lib.mkOption {
      type = lib.types.str;
      default = "FFFF33";
      description = "Hex color (RRGGBB) when the LLM is idle";
    };

    timeoutSeconds = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Seconds of no traffic before switching back to idle color";
    };

    pollIntervalSeconds = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "How often to check for traffic (in seconds)";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.llm-rgb = {
      description = "LLM RGB Monitor";
      after = [ "network.target" "openrgb.service" ];
      wants = [ "openrgb.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${monitorScript}/bin/llm-rgb-monitor";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
