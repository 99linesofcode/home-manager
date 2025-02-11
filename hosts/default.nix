{
  pkgs,
  specialArgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
  inherit (specialArgs) hostname username;
  if-exists = f: builtins.pathExists f;
  existing-imports = imports: builtins.filter if-exists imports;

  homeDir =
    if isDarwin
    then "/Users/"
    else "/home/";
in {
  imports =
    [
      ./shared
    ]
    ++ existing-imports [
      ./${hostname}
      ./${hostname}.nix
    ];

  home = {
    inherit username;
    homeDirectory = homeDir + username;
  };
}
