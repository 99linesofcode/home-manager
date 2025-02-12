{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.dunst;
in
  with lib; {
    options = {
      home.dunst.enable = mkEnableOption "dunst notifications manager";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        libnotify
      ];

      services.dunst = {
        enable = true;
      };
    };
  }
