{
  description = "NixOS configuration for Guillermo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    {
      specialArgs = { inherit inputs; };
      nixosConfigurations.guillermo = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/configuration.nix
          ./modules/desktop.nix
          ./modules/programs.nix
          home-manager.nixosModule
        ];
      };
    };
}
