{
  config,
  inputs,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) hostname username;
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
      sops
      ssh-to-age
    ];

    sops = {
      defaultSopsFile = "../hosts/${hostname}/users/${username}/secrets/secrets.yaml";
      age = {
        generateKey = true;
        keyFile = "${config.xdg.configHome}/sops/age/${username}.txt";
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };
  };
}
