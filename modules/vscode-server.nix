{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.home.vscode-server;
in
with lib;
{
  imports = [
    inputs.vscode-server.homeModules.default
  ];

  options = {
    home.vscode-server.enable = mkEnableOption "VSCode Server";
  };

  config = mkIf cfg.enable {
    services.vscode-server.enable = true;
  };
}
