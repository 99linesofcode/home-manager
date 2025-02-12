{
  lib,
  pkgs,
  ...
}:
with lib; {
  host.dunst.enable = true;
  host.firefox.enable = true;
  host.git.enable = true;
  host.hyprland.enable = true;
  host.keyring.enable = true;
  host.mpv.enable = true;
  host.nvim.enable = true;
  host.openssh.enable = true;
  host.rclone.enable = true;
  host.steam.enable = true;
  host.sops.enable = true;
  host.stylix.enable = true;
  host.waybar.enable = true;
  host.yazi.enable = true;
  host.zellij.enable = true;
  host.zsh.enable = true;

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
