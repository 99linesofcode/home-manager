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

          # automatically prune branches both local and remote
          function gpb {
            git checkout "$(git_main_branch)"
            git fetch
            git remote prune origin
            git branch --merged | grep -vE "$(git_main_branch)|$(git_develop_branch)" | xargs -r git branch -d
          }

          # git remove submodule
          function grms {
            git rm $PWD/$1
            rm -rf $PWD/.git/modules/$1
            git config --remove-section submodule.$1
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
            "git"
            "history"
            "laravel"
            "rails"
            "ssh-agent"
          ];
          theme = "juanghurtado";
        };
        profileExtra = ''
          if uwsm check may-start && uwsm select; then
            exec systemd-cat -t uwsm_start uwsm start default
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
