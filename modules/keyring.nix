{
  config,
  lib,
  ...
}:
let
  cfg = config.home.keyring;
in
with lib;
{
  options = {
    home.keyring.enable = mkEnableOption "gnome-keyring";
  };

  config = mkIf cfg.enable {
    services = {
      gnome-keyring = {
        enable = true;
        components = [
          "pkcs11"
          "secrets"
          "ssh"
        ];
      };
    };
  };
}
