{
  config,
  lib,
  ...
}:
let
  cfg = config.home.zathura;
in
with lib;
{
  options.home.zathura = with types; {
    enable = mkEnableOption "zathura";
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
          "application/illustrator"
          "application/oxps"
          "application/pdf"
          "application/postscript"
          "application/vnd.comicbook+zip"
          "application/vnd.comicbook-rar"
          "application/vnd.ms-xpsdocument"
          "application/x-bzdvi"
          "application/x-bzpdf"
          "application/x-bzpostscript"
          "application/x-cb7"
          "application/x-cbr"
          "application/x-cbt"
          "application/x-cbz"
          "application/x-dvi"
          "application/x-ext-cb7"
          "application/x-ext-cbr"
          "application/x-ext-cbt"
          "application/x-ext-cbz"
          "application/x-ext-djv"
          "application/x-ext-djvu"
          "application/x-ext-dvi"
          "application/x-ext-eps"
          "application/x-ext-pdf"
          "application/x-ext-ps"
          "application/x-gzdvi"
          "application/x-gzpdf"
          "application/x-gzpostscript"
          "application/x-xzpdf"
          "image/vnd.djvu+multipage"
          "image/x-bzeps"
          "image/x-eps"
          "image/x-gzeps"
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    programs.zathura.enable = true;

    xdg.mimeApps.defaultApplications = mkIf cfg.defaultApplication.enable (
      lib.genAttrs cfg.defaultApplication.mimeTypes (_: "zathura.desktop")
    );
  };
}
