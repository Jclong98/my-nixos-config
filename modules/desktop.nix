# Desktop environment: KDE Plasma 6, SDDM display manager, US keymap, and user config.

{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # KDE Plasma 6 with SDDM login manager.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
