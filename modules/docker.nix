{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.docker;
in
with lib;
{
  options = {
    home.docker.enable = mkEnableOption "docker";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        docker-credential-helpers
      ];
    };
  };
}
