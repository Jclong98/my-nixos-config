# Home Manager configuration for guillermo.
# Loaded via home-manager.nixosModules.home-manager in flake.nix.

{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager.users.guillermo = {
    home.packages = with pkgs; [
      kdePackages.kate
    ];

    programs.git = {
      settings.user.name = "Jacob Long";
      settings.user.email = "jclong98@gmail.com";
    };

    home.stateVersion = "26.05";
  };
}
