{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.bitwarden;
in
with lib;
{
  options = {
    home.bitwarden.enable = mkEnableOption "bitwarden";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      bitwarden_client_id = {
        format = "binary";
        sopsFile = ../hosts/shared/secrets/bitwarden_client_id;
      };
      bitwarden_client_secret = {
        format = "binary";
        sopsFile = ../hosts/shared/secrets/bitwarden_client_secret;
      };
    };

    home = {
      packages = with pkgs; [
        bitwarden-cli
      ];
    };
  };
}
