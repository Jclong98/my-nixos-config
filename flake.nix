{
  description = "NixOS configuration for Guillermo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      specialArgs = { inherit inputs; };
      nixosConfigurations.guillermo = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/configuration.nix
          ./modules/desktop.nix
          # ./modules/llm.nix
          # ./modules/minecraft.nix
          ./modules/programs.nix
        ];
      };
    };
}
