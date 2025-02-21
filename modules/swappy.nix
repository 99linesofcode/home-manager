{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.swappy;
in
with lib;
{
  options = {
    home.swappy.enable = mkEnableOption "swappy wayland screenshot editing tool";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      swappy
    ];
  };
}
