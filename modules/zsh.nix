{
  config,
  lib,
  ...
}: let
  cfg = config.host.zsh;
in
  with lib; {
    options = {
      host.zsh.enable = mkEnableOption "zsh";
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
            theme = "juanghurtado";
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
              "gpg-agent"
            ];
          };
          shellAliases = {
            a = "artisan";
            tinker = "artisan tinker";
            cat = "bat --paging=never";
            gl = "git sla";
            gfix = "git fix";
            kamal = "docker run -it --rm -v '$PWD:/workdir' -v '$SSH_AUTH_SOCK:/ssh-agent' -v /var/run/docker.sock:/var/run/docker.sock -e 'SSH_AUTH_SOCK=/ssh-agent' ghcr.io/basecamp/kamal:latest";
          };
          initExtra = ''
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

            fastfetch
          '';
        };
      };
    };
  }
