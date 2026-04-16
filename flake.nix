{
  description = "NixOS configuration for Guillermo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, ... } @ inputs: {
    nixosConfigurations.guillermo = {
      guillermo = pkgs.lib.nixosSystem {
        inherit system;
        modules = [ 
          ./nixos/configuration.nix 
        ];
      };
    };
  };
}
