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

      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      zoxide = {
        enable = true;
        options = [
          "--cmd cd"
        ];
        enableZshIntegration = true;
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
        initExtra = ''
          fastfetch

          function a() {
            if [ -f docker-compose.yml || -f docker-compose.yaml ]; then
              if docker ps -f "name=php" -f "publish=80" >/dev/null 2>&1; then
                docker compose exec php php artisan "$@"
              fi
            else
              php artisan "$@"
            fi
          }
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
            "fzf"
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
          tinker = "a tinker";
          cat = "bat --paging=never";
          kamal = "docker run -it --rm -v '$PWD:/workdir' -v '$SSH_AUTH_SOCK:/ssh-agent' -v /var/run/docker.sock:/var/run/docker.sock -e 'SSH_AUTH_SOCK=/ssh-agent' ghcr.io/basecamp/kamal:latest";
        };
      };
    };
  };
}
