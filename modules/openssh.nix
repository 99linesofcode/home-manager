{
  config,
  lib,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) hostname username;
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
        sopsFile = ../hosts/${hostname}/users/${username}/secrets/id_ed25519;
        path = config.home.homeDirectory + "/.ssh/id_ed25519";
        mode = "600";
      };
      "ssh/id_ed25519.pub" = {
        format = "binary";
        sopsFile = ../hosts/${hostname}/users/${username}/secrets/id_ed25519.pub;
        path = config.home.homeDirectory + "/.ssh/id_ed25519.pub";
        mode = "600";
      };
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "*.${s}${_p}${_a}${m}${t}${r}${a_}${p_}" = {
          forwardAgent = true;
          serverAliveInterval = 30;
        };
      };
    };
  };
}
