{
  config,
  inputs,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
  inherit (specialArgs) hostname username;
  cfg = config.home.sops;
in
  with lib; {
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

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        enableExtraSocket = false;
        enableZshIntegration = config.programs.zsh.enable;
        pinentryPackage = pkgs.pinentry-gnome3;
      };

      programs.gpg = {
        enable = true;
      };

      sops = {
        age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
        defaultSopsFile = ../hosts/${hostname}/secrets/secrets.yaml;
      };
    };
  }
