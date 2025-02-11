{
  lib,
  pkgs,
  ...
}: let
  locale = "en_US.UTF-8";
in
  with lib; {
    home = {
      packages = with pkgs; [
        hunspell
        hunspellDicts.en_GB-ise
        hunspellDicts.en_US
        hunspellDicts.nl_NL
      ];
      language = {
        address = mkDefault locale;
        base = mkDefault locale;
        collate = mkDefault locale;
        ctype = mkDefault locale;
        measurement = mkDefault locale;
        messages = mkDefault locale;
        monetary = mkDefault locale;
        name = mkDefault locale;
        numeric = mkDefault locale;
        paper = mkDefault locale;
        telephone = mkDefault locale;
        time = mkDefault locale;
      };
    };
  }
