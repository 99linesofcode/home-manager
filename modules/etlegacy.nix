{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.etlegacy;
  etConfig = pkgs.fetchFromGitHub {
    owner = "99linesofcode";
    repo = "etconfig";
    rev = "main";
    sha256 = "sha256-Yvqs4sRIH0RP5upV9PS8vm4cnZYFJMlEOZduN0WmRKg=";
  };
in
with lib;
{
  options = {
    home.etlegacy.enable = mkEnableOption "Open Source Wolfenstein Enemy Territory";
  };

  config = mkIf cfg.enable {
    home = {
      file.".etlegacy/etmain" = {
        source = etConfig;
        recursive = true;
      };

      packages = with pkgs; [
        etlegacy
      ];
    };
  };
}
