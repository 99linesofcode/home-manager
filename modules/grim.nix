{
  config,
  lib,
  pkgs,
  ...
}:
let
  hyprland = config.home.hyprland.enable;
  slurp = config.home.slurp.enable;
  swappy = config.home.swappy.enable;
  canScreenshot = hyprland && slurp && swappy;
  cfg = config.home.grim;
in
with lib;
{
  options = {
    home.grim.enable = mkEnableOption "grim screenshots";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      grim
    ];

    wayland.windowManager.hyprland.settings = mkIf canScreenshot {
      bind = [
        "SUPER, S, exec, grim -g \"$(slurp)\" - | swappy -f - | wl-copy"
      ];
    };
  };
}
