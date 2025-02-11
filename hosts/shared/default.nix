{specialArgs, ...}: let
  inherit (specialArgs) role username;
  if-exists = f: builtins.pathExists f;
  existing-imports = imports: builtins.filter if-exists imports;
in {
  imports =
    [
      ./nix.nix
    ]
    ++ existing-imports [
      ./role/${role}.nix
      ./users/${username}
      ./users/${username}.nix
    ];
}
