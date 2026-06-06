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
    nixpkgs.config.permittedInsecurePackages = [
      "electron-39.8.10"
    ];

    home = {
      packages = with pkgs; [
        discord
      ];
    };
  };
}
