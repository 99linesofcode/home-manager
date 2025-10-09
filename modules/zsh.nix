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
        initContent = ''
          fastfetch

          function p() {
            if [ -f docker-compose.yml ] || [ -f docker-compose.yaml ]; then
              if docker ps -f "name=php" -f "publish=80" --format "{{.ID}}" | grep -q .; then
                docker compose exec php $@
                return
              fi
            fi

            # TODO: local PHP should probably take precedence when dnsmasq is setup correctly
            if command -v php >/dev/null 2>&1; then
              $@
              return
            fi

            echo "Failed to run $@. Could not find PHP or PHP docker container."
            return 1
          }
        '';
        oh-my-zsh = {
          enable = true;
          plugins = [
            "asdf"
            "colorize"
            "colored-man-pages"
            "docker"
            "docker-compose"
            "fzf"
            "git"
            "ssh-agent"
          ];
          theme = "juanghurtado";
        };
        profileExtra = mkIf config.home.wayland.enable ''
          if uwsm check may-start; then
            exec uwsm start default
          fi
        '';
        syntaxHighlighting.enable = true;
        shellAliases = {
          a = "p php artisan";
          artisan = "a";
          cat = "bat --paging=never";
          c = "p composer";
          composer = "c";
          tinker = "a tinker";
          kamal = "docker run -it --rm -v '$PWD:/workdir' -v '$SSH_AUTH_SOCK:/ssh-agent' -v /var/run/docker.sock:/var/run/docker.sock -e 'SSH_AUTH_SOCK=/ssh-agent' ghcr.io/basecamp/kamal:latest";
        };
      };
    };
  };
}
