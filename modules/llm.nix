{ config, pkgs, ... }:

{
  # Local LLM related services
  # services.ollama = {
  #   enable = true;
  #   openFirewall = true;

  #   loadModels = [
  #     "gemma4:e2b"
  #   ];
  # };

  # open-webui (port 8080 by default)
  # services.open-webui = {
  #   enable = true;
  #   openFirewall = true;
  #   host = "0.0.0.0";
  # };
}
