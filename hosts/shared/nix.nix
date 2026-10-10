{
  lib,
  pkgs,
  ...
}:
with lib;
{
  nix = {
    gc = {
      automatic = true;
      dates = mkDefault "weekly";
      persistent = mkDefault true;
      options = "--delete-older-than 14d";
    };
    package = pkgs.nix;
    settings = {
      auto-optimise-store = mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      use-xdg-base-directories = mkDefault true;
    };
  };

  home = {
    packages = with pkgs; [
      nixd
      nixfmt
    ];
  };
}
