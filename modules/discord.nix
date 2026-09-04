{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.discord;
in
with lib;
{
  options = {
    home.discord.enable = mkEnableOption "discord";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        discord
      ];
    };
  };
}
