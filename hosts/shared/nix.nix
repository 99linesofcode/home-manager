{
  lib,
  pkgs,
  ...
}:
with lib; {
  nixpkgs = {
    config = {
      allowUnfree = mkDefault true;
      allowUnfreePredicate = _: true;
    };
  };

  nix = {
    package = pkgs.nix;
    settings = {
      auto-optimise-store = mkDefault true;
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = mkDefault true;
    };
  };
}
