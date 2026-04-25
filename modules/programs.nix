# Shell integrations, system packages, and user configuration.
# This module handles: program shell completions, system-wide packages,
# nix-ld (for VS Code remote SSH), and the user account.

{ config, pkgs, ... }:

{
  users.users.guillermo = {
    isNormalUser = true;
    description = "guillermo";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  programs = {
    firefox.enable = true;

    git = {
      enable = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
    };

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
      ];
    };

    htop.enable = true;

    # Allows VS Code remote-SSH to work from other machines.
    nix-ld.enable = true;
  };

  # System-wide packages available in all shells.
  environment.systemPackages = with pkgs; [
    wget
    docker
    fastfetch
    nixfmt
    llama-cpp-vulkan
  ];
}
