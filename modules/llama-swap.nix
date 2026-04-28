{ config, pkgs, ... }:

{
  services.llama-swap = {
    enable = true;
    openFirewall = true;

    settings = {
        models = {
            
        }
    }
  }
}
