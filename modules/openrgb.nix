# https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/hardware/openrgb.nix

{ pkgs, lib, ... }:

{
  services.hardware.openrgb = { 
    enable = true; 
    package = pkgs.openrgb-with-all-plugins; 
    motherboard = "amd"; 
  };
}