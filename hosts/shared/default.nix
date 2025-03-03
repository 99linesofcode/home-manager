{ pkgs, specialArgs, ... }:
let
  inherit (specialArgs) role username;
  if-exists = f: builtins.pathExists f;
  existing-imports = imports: builtins.filter if-exists imports;
in
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
}
