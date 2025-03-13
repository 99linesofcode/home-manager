{
  config,
  inputs,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) username;
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
      age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    };
  };
}
