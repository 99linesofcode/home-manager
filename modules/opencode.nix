{
  config,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.home.opencode;
in
with lib;
{
  options = {
    home.opencode = {
      enable = mkEnableOption "opencode";
      settings = mkOption {
        type = types.attrs;
        default = {
          autoupdate = false;
          default_agent = "orchestrator";
          agent = {
            build.disable = true;
            plan.disable = true;
            general.disable = true;
            explore.disable = true;
            scout.disable = true;
          };
          permission = {
            bash = {
              "*" = "allow";
              # privilege escalation
              "doas *" = "deny";
              "su *" = "deny";
              "sudo *" = "deny";
              # system state changes
              "halt *" = "deny";
              "poweroff *" = "deny";
              "reboot *" = "deny";
              "shutdown *" = "deny";
              "systemctl emergency *" = "deny";
              "systemctl halt *" = "deny";
              "systemctl isolate *" = "deny";
              "systemctl kexec *" = "deny";
              "systemctl poweroff *" = "deny";
              "systemctl reboot *" = "deny";
              "systemctl rescue *" = "deny";
              "systemctl switch-root *" = "deny";
              # disk / partition destruction
              "blkdiscard *" = "deny";
              "btrfs *" = "deny";
              "cryptsetup *" = "deny";
              "dd *" = "deny";
              "fdisk *" = "deny";
              "gdisk *" = "deny";
              "lvcreate *" = "deny";
              "lvreduce *" = "deny";
              "lvremove *" = "deny";
              "lvresize *" = "deny";
              "mdadm *" = "deny";
              "mkfs *" = "deny";
              "parted *" = "deny";
              "pvcreate *" = "deny";
              "pvremove *" = "deny";
              "sfdisk *" = "deny";
              "shred *" = "deny";
              "vgcreate *" = "deny";
              "vgremove *" = "deny";
              "wipefs *" = "deny";
              "zfs destroy *" = "deny";
              "zpool *" = "deny";
              # recursive permission changes on system roots
              "chmod -R 777 /" = "deny";
              "chmod -R 777 / *" = "deny";
              "chown -R * /" = "deny";
              "chown -R * /*" = "deny";
              # destructive rm on system paths
              "find / -delete *" = "deny";
              "rm -rf ${config.home.homeDirectory}*" = "deny";
              "rm -rf ${config.home.homeDirectory}/Development*" = "allow";
              "rm -rf ${config.home.homeDirectory}/Documents/Obsidian*" = "allow";
              "rm -rf ${config.xdg.configHome}*" = "deny";
              "rm -rf /" = "deny";
              "rm -rf /boot*" = "deny";
              "rm -rf /etc*" = "deny";
              "rm -rf /nix*" = "deny";
              "rm -rf /usr*" = "deny";
              "rm -rf /var*" = "deny";
              # remote code execution via pipe-to-shell
              "curl * | sh" = "deny";
              "curl * | bash" = "deny";
              "wget * | sh" = "deny";
              "wget * | bash" = "deny";
              # nix store / system config destruction
              "nix-collect-garbage -d" = "deny";
              "nix-store --delete *" = "deny";
              "nixos-rebuild switch *" = "deny";
              "nixos-rebuild boot *" = "deny";
              "nixos-rebuild test *" = "deny";
              "home-manager switch *" = "deny";
              # git history destruction
              "git push --force *" = "deny";
              "git push -f *" = "deny";
              "git filter-branch *" = "deny";
              "git filter-repo *" = "deny";
              # git branch force-delete (unmerged/unpushed work)
              "git branch -D *" = "deny";
              "git branch -Df *" = "deny";
              "git branch -fD *" = "deny";
              "git branch -df *" = "deny";
              "git branch -fd *" = "deny";
              "git branch -d -f *" = "deny";
              "git branch -f -d *" = "deny";
              "git branch --delete --force *" = "deny";
              "git branch --force --delete *" = "deny";
              # git remote branch deletion
              "git push --delete *" = "deny";
              "git push * --delete *" = "deny";
              "git push * :*" = "deny";
            };
            edit = "allow";
            external_directory = "allow";
            glob = "allow";
            grep = "allow";
            lsp = "allow";
            question = "allow";
            read = "allow";
            skill = "allow";
            todowrite = "deny"; # NOTE: todos are managed by wayfinder skill
            webfetch = "allow";
            websearch = "allow";
            write = "allow";
          };
          watcher = {
            ignore = [
              ".direnv/**"
              ".git/**"
              "dist/**"
              "node_modules/**"
            ];
          };
          # plugin = [
          #   "/home/shorty/Development/opencode-socket-plugin"
          # ];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      opencode = {
        format = "dotenv";
        sopsFile = "${self}/hosts/shared/secrets/opencode.env";
      };
    };

    programs = {
      opencode = {
        enable = true;
        enableMcpIntegration = true;
        agents = ../.opencode/agents;
        settings = cfg.settings;
        skills = ../.opencode/skills;
      };
      mcp = {
        enable = true;
        servers = {
          gmail = {
            type = "remote";
            url = "https://gmailmcp.googleapis.com/mcp/v1";
          };
          google-drive = {
            type = "remote";
            url = "https://drivemcp.googleapis.com/mcp/v1";
          };
          google-calendar = {
            type = "remote";
            url = "https://calendarmcp.googleapis.com/mcp/v1";
          };
          todoist = {
            type = "remote";
            url = "https://ai.todoist.net/mcp";
          };
          beeper = {
            type = "remote";
            url = "http://localhost:23373/v0/mcp";
          };
          shopify-dev = {
            type = "local";
            command = lib.getExe' pkgs.nodejs_22 "npx";
            args = [
              "-y"
              "@shopify/dev-mcp@latest"
            ];
          };
        };
      };
      zsh.initContent = mkIf config.home.zsh.enable (mkAfter
      # sh
      ''
        export $(cat ${config.sops.secrets.opencode.path})
      '');
    };
  };
}
