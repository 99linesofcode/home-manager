{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  home = {
    packages = with pkgs; [
      nix-prefetch-git
    ];

    alacritty.enable = true;
    docker.enable = true;
    eza.enable = true;
    feh = {
      enable = true;
      defaultApplication.enable = true;
    };
    git.enable = true;
    lazydocker.enable = true;
    nvim.enable = true;
    openssh.enable = true;
    rclone.enable = true;
    sops.enable = true;
    yazi.enable = true;
    zellij.enable = true;
    zsh.enable = true;
  };

  programs = {
    bat.enable = true;
    btop.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
