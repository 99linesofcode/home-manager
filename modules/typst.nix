{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) fullName;
  cfg = config.home.typst;
in
with lib;
{
  options = {
    home.typst.enable = mkEnableOption "typst";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        noto-fonts-cjk-sans-static
        noto-fonts-cjk-serif-static
        nix-unstable.typst
      ];
    };

    programs = {
      pandoc = {
        enable = true;
        defaults = {
          metadata = {
            author = "${fullName}";
          };
          pdf-engine = "typst";
          pdf-engine-opt = [
            "--font-path=${config.xdg.stateHome}/nix/profiles/profile/share/fonts"
          ];
        };
      };
    };
  };
}
