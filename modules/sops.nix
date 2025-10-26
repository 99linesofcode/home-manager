{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.sops;
in
with lib;
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  options = {
    home.sops.enable = mkEnableOption "secret management using sops";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      ssh-to-age
      sops
    ];

    sops = {
      defaultSopsFile = ../.sops.yaml;
      age = {
        generateKey = false;
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };
  };
}
