{
  config,
  lib,
  ...
}:
let
  cfg = config.home.gnome-keyring;
in
with lib;
{
  options = {
    home.gnome-keyring.enable = mkEnableOption "gnome-keyring";
  };

  config = mkIf cfg.enable {
    services.gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };
  };
}
