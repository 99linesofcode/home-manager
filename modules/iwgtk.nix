{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.iwgtk;
in
with lib;
{
  options = {
    home.iwgtk.enable = mkEnableOption "iwgtk front-end for iwd";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      iwgtk
    ];
  };
}
