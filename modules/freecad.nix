{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.freecad;

  freecadMcpAddon = pkgs.stdenvNoCC.mkDerivation {
    pname = "freecad-mcp-addon";
    version = "0.1.27";
    src = pkgs.fetchFromGitHub {
      owner = "neka-nat";
      repo = "freecad-mcp";
      rev = "78bf0230a03324b56c9a0b7f55150fb5be2a0d42";
      hash = "sha256-BGxa7+wa9QwiR1R2fs//ksMVfhzqklr0sybPwHYgIYQ=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r addon/FreeCADMCP $out/
      runHook postInstall
    '';
  };
in
with lib;
{
  options = {
    home.freecad.enable = mkEnableOption "freecad";
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        (pkgs.freecad.customize {
          makeWrapperFlags = [
            "--set"
            "LD_PRELOAD"
            "${lib.getLib pkgs.expat}/lib/libexpat.so.1"
          ];
        })
      ];
    };

    xdg.dataFile."FreeCAD/v1-1/Mod/FreeCADMCP" = {
      source = "${freecadMcpAddon}/FreeCADMCP";
      recursive = true;
    };

    programs = {
      mcp = {
        enable = true;
        servers = {
          freecad = {
            type = "local";
            command = lib.getExe' pkgs.uv "uvx";
            args = [
              "--python"
              (lib.getExe pkgs.python313)
              "freecad-mcp"
            ];
            env = {
              UV_PYTHON_DOWNLOADS = "never";
            };
          };
        };
      };
    };
  };
}
