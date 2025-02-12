{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.home.yazi;
in
  with lib; {
    options = {
      home.yazi.enable = mkEnableOption "yazi";
    };

    config = mkIf cfg.enable {
      home.packages = with pkgs; [
        ueberzugpp
      ];

      programs.yazi.enable = true;
    };
  }
