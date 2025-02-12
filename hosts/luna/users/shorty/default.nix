{
  lib,
  pkgs,
  ...
}:
with lib; {
  home.dunst.enable = true;
  home.firefox.enable = true;
  home.git.enable = true;
  home.hyprland.enable = true;
  home.keyring.enable = true;
  home.mpv.enable = true;
  home.nvim.enable = true;
  home.openssh.enable = true;
  home.rclone.enable = true;
  home.steam.enable = true;
  home.sops.enable = true;
  home.stylix.enable = true;
  home.waybar.enable = true;
  home.yazi.enable = true;
  home.zellij.enable = true;
  home.zsh.enable = true;

  home = {
    packages = with pkgs; [
      android-tools
      beeper
      bitwarden
      bitwarden-cli
      bws
      electron
      (freecad.override {withWayland = true;})
      # figlet
      # gcc
      lazydocker
      nix-prefetch-git
      obsidian
      polychromatic
      rustdesk
      scrcpy
      skypeforlinux
      webcord
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
    direnv.enable = true;
    # eza.enable = true; # rust based ls replacement
    feh.enable = true; # image viewer
    obs-studio.enable = true;
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };
    vscode.enable = true;
    yt-dlp.enable = true;
    zathura.enable = true;
  };
}
