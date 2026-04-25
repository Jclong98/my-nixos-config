# Shell integrations, system packages, and the NixOS user account setup.
# Home Manager (configuration.nix) handles per-user dotfiles and programs.

{ config, pkgs, ... }:

{
  # System user account — groups and basic info.
  # Per-user config (dotfiles, git, etc.) is in home-manager.
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

    # Git shell completions (system-wide). Per-user git config is in home-manager.
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
