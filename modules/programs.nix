# Shell integrations, system packages, and user configuration.
# This module handles: program shell completions, system-wide packages,
# git config, nix-ld (for VS Code remote SSH), and the user account.

{ config, pkgs, ... }:

{
  users.users.guillermo = {
    isNormalUser = true;
    description = "guillermo";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs = {
    firefox.enable = true;

    git = {
      enable = true;
      config = {
        user.name = "Jacob Long";
        user.email = "jclong98@gmail.com";
        init.defaultBranch = "main";
        pull.rebase = true;
      };
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
