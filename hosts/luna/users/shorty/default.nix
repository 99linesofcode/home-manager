{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  home.nix.enable = true;

  home.bluetui.enable = true;
  home.brightnessctl.enable = true;
  home.dunst.enable = true;
  home.firefox.enable = true;
  home.git.enable = true;
  home.grim.enable = true;
  home.hyprland.enable = true;
  # home.hyprlock.enable = true; # TODO: needs to be configured
  home.hypridle.enable = true;
  home.hyprpaper.enable = true;
  # home.hyprpolkitagent.enable = true;
  # home.hyprshade.enable = true;
  home.iwgtk.enable = true;
  home.keyring.enable = true;
  home.mpv.enable = true;
  home.nvim.enable = true;
  # home.nwg-dock-hyprland.enable = true; # TODO: not sure how I feel about this yet
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
  home.vscode.enable = true;
  home.vscode-server.enable = true;
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
      bws
      discord
      electron
      (freecad.override { withWayland = config.home.wayland.enable; })
      nix-prefetch-git
      obsidian
      polychromatic
      rustdesk
      scrcpy
      # development tools
      android-tools
      act # run GitHub Actions locally
      # figlet
      # gcc
      lazydocker
      # debugging and reverse engineering
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
    # eza.enable = true; # rust based ls replacement
    feh.enable = true; # image viewer
    obs-studio.enable = true;
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      extraConfig.run-command = "${config.home.wayland.uwsm.prefix}{cmd}";
    };
    vscode.enable = true;
    yt-dlp.enable = true;
    zathura.enable = true;
  };
}
