# Host entry point for guillermo.
# A KDE Plasma 6 desktop with development tools.
# flake.nix loads this file plus home/guillermo.nix; module imports live here.

{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/desktop.nix
    ./modules/programs.nix
    ./modules/llama.nix
    ./modules/openrgb.nix
    ./modules/llm-rgb.nix
    # ./modules/minecraft.nix  # uncomment to enable the Minecraft server
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
  # Note: services open their own firewall ports (llama-server: 8080 in
  # nixos/modules/llama.nix). For one-off test ports, add them here,
  # rebuild, then remove them again.
  networking.firewall.allowedTCPPorts = [
    8000  # vllm docker-compose
  ];

  # Local user account — per-user config (dotfiles, git, packages) is in
  # home/guillermo.nix via Home Manager.
  users.users.guillermo = {
    isNormalUser = true;
    description = "guillermo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "render"
      "video"
    ];
  };

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

  # LLM RGB — turns fans red while llama-server is serving requests.
  # modules/llm-rgb.nix defines the options (colors, timeout, poll interval).
  # services.llm-rgb.enable = true;

  system.stateVersion = "26.05";
}
