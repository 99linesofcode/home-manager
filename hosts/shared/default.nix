{
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) role username;
  if-exists = f: builtins.pathExists f;
  existing-imports = imports: builtins.filter if-exists imports;
in
with lib;
{
  imports =
    [
      ./nix.nix
      ./locale.nix
    ]
    ++ existing-imports [
      ./role/${role}.nix
      ./users/${username}
      ./users/${username}.nix
    ];

  xdg = {
    mime.enable = mkDefault true;
    mimeApps.enable = mkDefault true;
  };

  home = {
    stateVersion = "25.05";
    packages = with pkgs; [
      imagemagick
      ffmpeg
      mupdf
      rsync
      tldr
      wireguard-tools
      xdg-utils
      xdg-user-dirs
      # compression and extraction
      unzip
      wget
      zip
    ];
  };

  programs = {
    alacritty = {
      enable = true;
      settings = {
        font.offset.y = 8;
      };
    };
  };
}
