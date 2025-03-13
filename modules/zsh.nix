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
      direnv = mkIf config.programs.direnv.enable {
        enableZshIntegration = true;
      };
      fastfetch.enable = true;
      yazi = mkIf config.programs.yazi.enable {
        enableZshIntegration = true;
      };
      zoxide = {
        enable = true;
        options = [
          "--cmd cd"
        ];
      };
      zsh = {
        enable = true;
        enableCompletion = true; # NOTE: add environment.pathsToLink = [ "/share/zsh" ]; to system when running NixOS
        autosuggestion.enable = true;
        history.ignoreAllDups = true;
        historySubstringSearch.enable = true;
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
        shellAliases = {
          a = "artisan";
          tinker = "artisan tinker";
          cat = "bat --paging=never";
          kamal = "docker run -it --rm -v '$PWD:/workdir' -v '$SSH_AUTH_SOCK:/ssh-agent' -v /var/run/docker.sock:/var/run/docker.sock -e 'SSH_AUTH_SOCK=/ssh-agent' ghcr.io/basecamp/kamal:latest";
        };
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
      };
    };
  };
}
