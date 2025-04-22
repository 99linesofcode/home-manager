{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (specialArgs) username;
  cfg = config.home.vscode;
in
with lib;
{
  options = {
    home.vscode.enable = mkEnableOption "Visual Studio Code";
  };

  config = mkIf cfg.enable {
    # TODO: vscode configure keyring

    programs.vscode = {
      enable = true;
      profiles.${username} = {
        extensions = with pkgs.vscode-marketplace; [
          asvetliakov.vscode-neovim
          bradlc.vscode-tailwindcss
          bierner.markdown-mermaid
          editorconfig.editorconfig
          github.vscode-github-actions
          gruntfuggly.todo-tree
          m1guelpf.better-pest
          mikestead.dotenv
          ms-vscode-remote.vscode-remote-extensionpack
          ms-vscode.vscode-speech
          naumovs.color-highlight
          saoudrizwan.claude-dev # cline
          yo1dog.cursor-align
          vadimcn.vscode-lldb
          waderyan.gitblame

          # linters, highlighters and formatters
          brettm12345.nixfmt-vscode
          davidanson.vscode-markdownlint
          dbaeumer.vscode-eslint
          evgeniypeshkov.syntax-highlighter
          foxundermoon.shell-format
          ms-azuretools.vscode-docker
          ms-python.black-formatter
          open-southeners.laravel-pint
          redhat.vscode-yaml
          statiolake.vscode-rustfmt
          stylelint.vscode-stylelint
          yzhang.markdown-all-in-one

          # PHP
          bmewburn.vscode-intelephense-client
          laravel.vscode-laravel
          onecentlin.laravel5-snippets
          onecentlin.laravel-blade
          # phpactor.vscode-phpactor
          # sanderronde.phpstan-vscode
          xdebug.php-debug
        ];
        keybindings = [
          {
            "key" = "ctrl+b";
            "command" = "workbench.action.toggleSidebarVisibility";
          }
        ];
        userSettings = {
          "diffEditor.ignoreTrimWhitespace" = false;
          "diffEditor.renderSideBySide" = true;
          "editor.bracketPairColorization.enabled" = true;
          "editor.cursorBlinking" = "smooth";
          "editor.detectIndentation" = false;
          "editor.fontSize" = mkForce 14;
          "editor.formatOnSave" = true;
          "editor.formatOnPaste" = false;
          "editor.guides.bracketPairs" = "active";
          "editor.insertSpaces" = true;
          "editor.inlineSuggest.enabled" = true;
          "editor.lineNumbers" = "relative";
          "editor.lineHeight" = 30;
          "editor.minimap.enabled" = false;
          "editor.semanticHighlighting.enabled" = true;
          "editor.quickSuggestions" = {
            "comments" = true;
          };
          "editor.quickSuggestionsDelay" = 0;
          "editor.renderWhitespace" = "all";
          "editor.rulers" = [
            80
            120
            160
          ];
          "editor.tabSize" = 2;
          "files.associations" = {
            ".php-cs-fixer*" = "php";
          };
          "files.trimTrailingWhitespace" = true;
          "laravel-pint.enable" = true;
          "search.useIgnoreFiles" = false;
          "window.menuBarVisibility" = "compact";
          "window.titleBarStyle" = "native";
          "window.zoomLevel" = 0;
          "workbench.sideBar.location" = "right";
          "workbench.startupEditor" = "none";

          # laravel-blade formatter
          "blade.format.enable" = true;

          # emmet
          "emmet.includeLanguages" = {
            "blade" = "html";
            "vue" = "html";
            "vue-html" = "html";
          };

          # css
          "stylelint.validate" = [
            "css"
            "scss"
          ];
          "tailwindCss.emmetCompletions" = true;

          # javascript
          "eslint.format.enable" = true;
          "esint.validate" = [
            "javascript"
            "typescript"
            "javascriptreact"
            "typescriptreact"
          ];

          # disable for intelephese
          "php.suggest.basic" = false;
          "php.validate.enable" = false;

          # git
          "git.autofetch" = true;
          "git.ignoreLegacyWarning" = true;
          "git.ignoreMissingGitWarning" = true;
          "git.openRepositoryInParentFolders" = "never";
          "git.showPushSuccessNotification" = true;
          "git.suggestSmartCommit" = false;

          # html formatting
          "html.format" = {
            "wrapAttributes" = "force-expand-multiline";
          };

          # todo tree
          "todo-tree.tree.autoRefresh" = true;

          # telemetry
          "redhat.telemetry.enabled" = false;
          "telemetry.telemetryLevel" = "off";
          "update.mode" = "none";

          # formatting
          "[dockerfile]" = {
            "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
          };
          "[javascript][typescript][vue][javascriptreact][typescriptreact]" = {
            "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
          };
          "[markdown]" = {
            "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
          };
          "[php]" = {
            "editor.defaultFormatter" = "open-southeners.laravel-pint";
          };
          "[python]" = {
            "editor.defaultFormatter" = "ms-python.black-formatter";
          };
          "[rust]" = {
            "editor.defaultFormatter" = "statiolake.vscode-rustfmt";
          };
          "[shellscript]" = {
            "editor.defaultFormatter" = "foxundermoon.shell-format";
          };
          "[yaml]" = {
            "editor.defaultFormatter" = "redhat.vscode-yaml";
          };

          "extensions.experimental.affinity" = {
            "asvetliakov.vscode-neovim" = 1;
          };
        };
      };
    };
  };
}
