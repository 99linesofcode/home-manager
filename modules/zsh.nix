{
  config,
  lib,
  ...
}:
let
  cfg = config.home.zsh;
in
with lib;
{
  options = {
    home.zsh.enable = mkEnableOption "zsh";
  };

  config = mkIf cfg.enable {
    programs = {
      fastfetch.enable = true;

      zoxide = {
        enable = true;
        options = [
          "--cmd cd"
        ];
      };

      zsh = {
        enable = true;
        autosuggestion.enable = true;
        history = {
          ignoreAllDups = true;
          ignorePatterns = [
            "cd *"
            "pkill *"
            "rm *"
          ];
        };
        historySubstringSearch.enable = true;
        initExtra = ''
          fastfetch
        '';
        oh-my-zsh = {
          enable = true;
          plugins = [
            "asdf"
            "colorize"
            "colored-man-pages"
            "composer"
            "docker"
            "docker-compose"
            "git"
            "laravel"
            "rails"
            "ssh-agent"
          ];
          theme = "juanghurtado";
        };
        profileExtra = ''
          if uwsm check may-start; then
            exec uwsm start default
          fi
        '';
        syntaxHighlighting.enable = true;
        shellAliases = {
          a = "artisan";
          tinker = "artisan tinker";
          cat = "bat --paging=never";
          kamal = "docker run -it --rm -v '$PWD:/workdir' -v '$SSH_AUTH_SOCK:/ssh-agent' -v /var/run/docker.sock:/var/run/docker.sock -e 'SSH_AUTH_SOCK=/ssh-agent' ghcr.io/basecamp/kamal:latest";
        };
      };
    };
  };
}
