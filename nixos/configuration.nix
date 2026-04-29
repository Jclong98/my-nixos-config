# Main system configuration for guillermo
# A KDE Plasma 6 desktop with development tools.
# Loaded by flake.nix → nixos/configuration.nix

{ inputs, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flake commands
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "guillermo";
  networking.networkmanager.enable = true;

  # Open ports in the firewall (used by open-webui on port 8080).
  networking.firewall.allowedTCPPorts = [ 8080 3333 ];
  networking.firewall.allowedUDPPorts = [ 8080 3333 ];

  time.timeZone = "America/Phoenix";
  i18n.defaultLocale = "en_US.UTF-8";

  # All locale settings to English (US).
  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.hardware.openrgb.enable = true;

  # Docker daemon.
  virtualisation.docker.enable = true;

  # Console keymap.
  console.keyMap = "us";

  # Never sleep, suspend, or hibernate (always-on machine).
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # Garbage collection for always-on machine.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "26.05";
}
