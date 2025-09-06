{
  config,
  lib,
  ...
}:
let
  cfg = config.home.pass;
in
with lib;
{
  options = {
    home.pass.enable = mkEnableOption "pass";
  };

  config = mkIf cfg.enable {
    programs = {
      password-store.enable = true;
    };

    services.pass-secret-service.enable = true;
  };
}
