{
  lib,
  pkgs,
  ...
}:
with lib;
{
  nix = {
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
      nil
      nixfmt-rfc-style
    ];
  };

}
