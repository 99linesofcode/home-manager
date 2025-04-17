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
          ms-vscode-remote.vscode-remote-extensionpack

          asvetliakov.vscode-neovim
          bradlc.vscode-tailwindcss
          bierner.markdown-mermaid
          eamodio.gitlens
          evgeniypeshkov.syntax-highlighter
          github.vscode-github-actions
          gruntfuggly.todo-tree
          laravel.vscode-laravel
          m1guelpf.better-pest
          mikestead.dotenv
          ms-azuretools.vscode-docker
          naumovs.color-highlight
          saoudrizwan.claude-dev # cline
          redhat.vscode-yaml
          yo1dog.cursor-align
          yzhang.markdown-all-in-one

          brettm12345.nixfmt-vscode
          davidanson.vscode-markdownlint
          dbaeumer.vscode-eslint
          editorconfig.editorconfig
          foxundermoon.shell-format
          open-southeners.laravel-pint
          ms-python.black-formatter
          sanderronde.phpstan-vscode
          statiolake.vscode-rustfmt
          stylelint.vscode-stylelint

          bmewburn.vscode-intelephense-client
          laravel.vscode-laravel

          vadimcn.vscode-lldb
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
          "editor.formatOnSave" = true;
          "editor.formatOnPaste" = false;
          "editor.guides.bracketPairs" = "active";
          "editor.insertSpaces" = true;
          "editor.inlineSuggest.enabled" = true;
          "editor.lineNumbers" = "relative";
          "editor.lineHeight" = 30;
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
          "files.trimTrailingWhitespace" = true;
          "laravel-pint.enable" = true;
          "search.useIgnoreFiles" = false;
          "window.menuBarVisibility" = "compact";
          "window.titleBarStyle" = "native";
          "window.zoomLevel" = 1;
          "workbench.sideBar.location" = "right";
          "workbench.startupEditor" = "none";

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

          # php
          "files.associations" = {
            ".php-cs-fixer*" = "php";
          };

          # git
          "git.autofetch" = true;
          "git.ignoreLegacyWarning" = true;
          "git.ignoreMissingGitWarning" = true;
          "git.openRepositoryInParentFolders" = "never";
          "git.showPushSuccessNotification" = true;
          "git.suggestSmartCommit" = false;

          # html formatting
          "html.format" = {
            "templating" = true;
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
          "[json][jsonc]" = {
            "editor.defaultFormatter" = "vscode.json-language-features";
          };
          "[html][blade]" = {
            "editor.defaultFormatter" = "vscode.html-language-features";
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
