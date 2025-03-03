{
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
  inherit (specialArgs) hostname username;
  if-exists = f: builtins.pathExists f;
  existing-imports = imports: builtins.filter if-exists imports;

  homeDir = if isDarwin then "/Users/" else "/home/";
in
with lib;
{
  imports =
    [
      ./shared
    ]
    ++ existing-imports [
      ./${hostname}
      ./${hostname}.nix
    ];

  nixpkgs = {
    config = {
      allowUnfree = mkDefault true;
      allowUnfreePredicate = _: true;
    };
  };

  news.display = "silent";

  home = {
    inherit username;
    homeDirectory = homeDir + username;
  };
}
