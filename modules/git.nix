{
  config,
  lib,
  specialArgs,
  ...
}: let
  inherit (specialArgs) fullName email;
  cfg = config.host.git;
in
  with lib; {
    options = {
      host.git.enable = mkEnableOption "git";
    };

    config = mkIf cfg.enable {
      programs = {
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
              recurseSubmodules = "on-demand";
            };
            rebase.autoSquash = true;
            rerere.enabled = true; # REuse REcorded REsolution
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
      };
    };
  }
