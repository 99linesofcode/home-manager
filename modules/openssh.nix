{
  config,
  lib,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) hostname;
  cfg = config.home.openssh;
  s = "99";
  _p = "li";
  _a = "nes";
  m = "of";
  t = "co";
  r = "de";
  a_ = ".";
  p_ = "nl";
in
with lib;
{
  options = {
    home.openssh.enable = mkEnableOption "openssh";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "ssh/id_ed25519" = {
        format = "binary";
        sopsFile = ../hosts/${hostname}/users/${config.home.username}/secrets/id_ed25519;
        path = config.home.homeDirectory + "/.ssh/id_ed25519";
        mode = "600";
      };
      "ssh/id_ed25519.pub" = {
        format = "binary";
        sopsFile = ../hosts/${hostname}/users/${config.home.username}/secrets/id_ed25519.pub;
        path = config.home.homeDirectory + "/.ssh/id_ed25519.pub";
        mode = "600";
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          AddKeysToAgent = "no";
          Compression = false;
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          ForwardAgent = true;
          HashKnownHosts = false;
          ServerAliveCountMax = 3;
          ServerAliveInterval = 30;
          UserKnownHostsFile = "~/.ssh/known_hosts";
        };
        "*.${s}${_p}${_a}${m}${t}${r}${a_}${p_}" = {
        };
      };
    };
  };
}
