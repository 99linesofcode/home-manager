{
  config,
  inputs,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  cfg = config.home.sops;
  inherit (specialArgs) username;
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
        keyFile = "/home/${username}/.config/sops/age/keys.txt";
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };
  };
}
