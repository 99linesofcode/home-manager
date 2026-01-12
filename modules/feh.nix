{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.feh;
in
with lib;
{
  options.home.feh = with types; {
    enable = mkEnableOption "feh - fast and light image viewer";
    defaultApplication = {
      enable = mkOption {
        description = "MIME default application configuration";
        type = bool;
        default = false;
      };
      mimeTypes = mkOption {
        description = "MIME types to be the default application for";
        type = listOf str;
        default = [
          "application/x-font-otf"
          "image/bmp"
          "image/gif"
          "image/heic"
          "image/jpeg"
          "image/pjpeg"
          "image/png"
          "image/svg+xml"
          "image/tiff"
          "image/x-xpixmap"
          "image/x-portable-anymap"
          "image/x-portable-graymap"
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    programs.feh = with pkgs; {
      enable = true;
      # package = feh.override { imlib2 = imlib2Full; }; # FIXME: wouldnt build for 4ebc11dad54b7e5b8a46c6edb2533852e99ec566bbe10836b2d6dba89c9c2e3c
    };

    xdg.mimeApps.defaultApplications = mkIf cfg.defaultApplication.enable (
      lib.genAttrs cfg.defaultApplication.mimeTypes (_: "feh.desktop")
    );
  };
}
