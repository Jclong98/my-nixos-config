# Minecraft Java Edition server (declarative mode).
# To enable, uncomment the import in flake.nix and rebuild.
#
# The server is managed via /var/lib/minecraft and its configuration
# is fully declarative — server.properties, whitelist, etc. are all
# defined in this file.

{ config, pkgs, ... }:

{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;

    declarative = true;

    serverProperties = {
      gamemode = "survival";
      difficulty = "hard";
      simulation-distance = 10;
      level-seed = "2026-04-16";
      motd = "👉😎👉";
      white-list = true;
    };

    whitelist = {
      jclong98 = "c097aec3-ac9a-4997-a8e9-9822e6b7b07c";
    };
  };
}
