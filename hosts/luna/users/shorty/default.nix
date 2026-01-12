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
      beeper
      bitwarden-desktop
      bitwarden-cli
      discord
      electron
      # (freecad.override { withWayland = config.home.wayland.enable; })
      freecad-wayland
      insomnia # FOSS alternative to Postman API tester
      nix-prefetch-git
      polychromatic
      # rustdesk
      scrcpy
      android-tools
      act # run GitHub Actions locally
      wireshark
      gdb
      # ghidra # FIXME: wouldnt build for 4ebc11dad54b7e5b8a46c6edb2533852e99ec566bbe10836b2d6dba89c9c2e3c
      scanmem
    ];

    bluetui.enable = true;
    brightnessctl.enable = true;
    dunst.enable = true;
    docker.enable = true;
    eza.enable = true;
    feh = {
      enable = true;
      defaultApplication.enable = true;
    };
    firefox = {
      enable = true;
      defaultApplication.enable = true;
    };
    gammastep.enable = true;
    git.enable = true;
    grim.enable = true;
    gnome-keyring.enable = true;
    google-drive.enable = true;
    hyprland.enable = true;
    impala.enable = true;
    lazydocker.enable = true;
    mpv.enable = true;
    nvim.enable = true;
    obsidian.enable = true;
    openssh.enable = true;
    playerctl.enable = true;
    pwvucontrol.enable = true;
    qalculate-gtk.enable = true;
    rclone.enable = true;
    slurp.enable = true;
    steam.enable = true;
    sops.enable = true;
    swappy.enable = true;
    stylix.enable = true;
    vscode.enable = true;
    vscode-server.enable = true;
    waybar.enable = true;
    wayland.enable = true;
    waypaper.enable = true;
    wlogout.enable = true;
    yazi.enable = true;
    zathura = {
      enable = true;
      defaultApplication.enable = true;
    };
    zellij.enable = true;
    zsh.enable = true;
  };

  programs = {
    bat.enable = true;
    btop.enable = true;
    chromium.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    obs-studio.enable = true;
    rofi = {
      enable = true;
      extraConfig.run-command = "${config.home.wayland.uwsm.prefix}{cmd}";
    };
    yt-dlp.enable = true;
  };
}
