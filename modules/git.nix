{
  config,
  lib,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) fullName email;
  cfg = config.home.git;
in
with lib;
{
  options = {
    home.git.enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {
    programs = {
      gh = {
        enable = true;
        settings = {
          color_labels = "enabled";
          git_protocol = "ssh";
        };
      };
      git = {
        enable = true;
        aliases = {
          fix = "commit --fixup";
          pufowile = "push --force-with-lease";
          sl = "log --oneline --decorate --graph";
          sla = "sl --all";
        };
        extraConfig = {
          branch.autoSetupRebase = "always";
          commit.gpgSign = true;
          core = {
            autocrlf = false;
            editor = "nvim";
            eol = "lf";
            excludesFile = "../dotfiles/git/.gitignore_global";
          };
          diff.submodule = "log";
          fetch.prune = true;
          gpg.format = "ssh";
          init.defaultBranch = "main";
          pull = {
            default = "current";
            rebase = true;
          };
          push = {
            default = "current";
            recurseSubmodules = "on-demand"; # push submodules before git push
          };
          rebase.autoSquash = true;
          rerere.enabled = true; # REuse REcorded REsolution
          submodule.recurse = true; # update submodules after pull
          status.submoduleSummary = true;
          tag.gpgSign = true;
        };
        userName = fullName;
        userEmail = email;
        signing.key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };
      lazygit = {
        enable = true;
        settings = {
          quitOnTopLevelReturn = true; # exit Lazygit when the user presses escape in a context where there is nothing to cancel/close
          git.overrideGpg = true; # do not spawn a separate process when using GPG
        };
      };
      zsh = mkIf config.programs.zsh.enable {
        initContent = ''
          # automatically prune branches both local and remote
          function gpb() {
            git checkout "$(git_main_branch)"
            git fetch
            git remote prune origin
            git branch --merged | grep -vE "$(git_main_branch)|$(git_develop_branch)" | xargs -r git branch -d
          }

          # git remove submodule
          function grms() {
            git rm $PWD/$1
            rm -rf $PWD/.git/modules/$1
            git config --remove-section submodule.$1
          }
        '';
        shellAliases = {
          gl = "git sla";
          gfix = "git fix";
          lz = "lazygit";
        };
      };
    };
  };
}
