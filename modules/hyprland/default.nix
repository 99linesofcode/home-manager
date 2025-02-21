{ lib, ... }:
let
  files = builtins.attrNames (builtins.readDir ./.);
  moduleFileNames = builtins.filter (f: f != "default.nix" && lib.hasSuffix "nix" f) files;
  moduleFilePaths = builtins.map (f: ./. + "/${f}") moduleFileNames;
in
{
  imports = moduleFilePaths;
}
