# Shell integrations and system-wide packages.
# The user account lives in nixos/configuration.nix;
# Home Manager (home/guillermo.nix) handles per-user dotfiles and programs.

{ config, pkgs, ... }:

{
  programs = {
    firefox.enable = true;

    # Git shell completions (system-wide). Per-user git config is in home-manager.
    git.enable = true;

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
    home-manager
    nvtopPackages.intel
    intel-oneapi-toolkit
  ];
}
