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

    # allows vscode remote-ssh to work from other machines
    nix-ld.enable = true;
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget
    docker
    fastfetch
    nixfmt
    llama-cpp-vulkan
  ];
}
