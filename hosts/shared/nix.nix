{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.nix;
in
with lib;
{
  options = {
    home.nix.enable = mkEnableOption "NixOS specific configuration settings";
  };

  config = mkIf cfg.enable {

    nix = {
      package = pkgs.nix;
      settings = {
        auto-optimise-store = mkDefault true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        use-xdg-base-directories = mkDefault true;
      };
    };
  };
}
