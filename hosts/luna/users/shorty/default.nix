{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  home.bluetui.enable = true;
  home.brightnessctl.enable = true;
  home.dunst.enable = true;
  home.eza.enable = true;
  home.firefox.enable = true;
  home.gammastep.enable = true;
  home.git.enable = true;
  home.grim.enable = true;
  home.google-drive.enable = true;
  home.hyprland.enable = true;
  home.keyring.enable = true;
  home.lazydocker.enable = true;
  home.mpv.enable = true;
  home.nvim.enable = true;
  home.obsidian.enable = true;
  home.openssh.enable = true;
  home.playerctl.enable = true;
  home.pwvucontrol.enable = true;
  home.qalculate-gtk.enable = true;
  home.rclone.enable = true;
  home.slurp.enable = true;
  home.steam.enable = true;
  home.sops.enable = true;
  home.swappy.enable = true;
  home.stylix.enable = true;
  home.waybar.enable = true;
  home.wayland.enable = true;
  home.waypaper.enable = true;
  home.wlogout.enable = true;
  home.yazi.enable = true;
  home.zellij.enable = true;
  home.zsh.enable = true;

  home = {
    packages = with pkgs; [
      beeper
      bitwarden
      bitwarden-cli
      discord
      electron
      (freecad.override { withWayland = config.home.wayland.enable; })
      nix-prefetch-git
      polychromatic
      # rustdesk
      scrcpy
      android-tools
      act # run GitHub Actions locally
      wireshark
      gdb
      ghidra
      scanmem
    ];
  };

  programs = {
    alacritty.enable = true;
    bat.enable = true;
    btop.enable = true;
    chromium.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    feh.enable = true; # image viewer
    obs-studio.enable = true;
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      extraConfig.run-command = "${config.home.wayland.uwsm.prefix}{cmd}";
    };
    yt-dlp.enable = true;
    zathura.enable = true;
  };
}
