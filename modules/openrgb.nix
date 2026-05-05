{ pkgs, ... }:

let
  set-green-rgb = pkgs.writeScriptBin "set-green-rgb" ''
    #!/bin/sh
    # Wait a moment for devices to be initialized
    sleep 2
    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -E '^[0-9]+: ' | wc -l)

    if [ "$NUM_DEVICES" -eq 0 ]; then
      echo "No RGB devices found."
      exit 0
    fi

    for i in $(seq 0 $((NUM_DEVICES - 1))); do
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --device $i --mode static --color 00FF00
    done
  '';
in
{
  # Hardware service
  services.hardware.openrgb.enable = true;

  # Install package
  environment.systemPackages = [ pkgs.openrgb ];

  # Required for hardware access as per docs
  services.udev.packages = [ pkgs.openrgb ];
  boot.kernelModules = [ "i2c-dev" ];
  hardware.i2c.enable = true;

  # Systemd service to set color on boot
  systemd.services.set-green-rgb = {
    description = "Set RGB devices to green";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${set-green-rgb}/bin/set-green-rgb";
      Type = "oneshot";
    };
  };
}
