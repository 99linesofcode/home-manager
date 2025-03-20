{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.lazydocker;
in
with lib;
{
  options = {
    home.lazydocker.enable = mkEnableOption "lazydocker";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        lazydocker
      ];
    };

    programs = {
      zsh = mkIf config.programs.zsh.enable {
        shellAliases = {
          gl = "git sla";
          gfix = "git fix";
          lz = "lazygit";
        };
      };
    };
  };
}
