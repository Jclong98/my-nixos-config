{ config, pkgs, ... }:

{
  # minecraft server
  # by default, this places the server in /var/lib/minecraft
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
