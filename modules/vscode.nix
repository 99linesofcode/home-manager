{
  config,
  lib,
  pkgs,
  ...
}:
let
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
      profiles.default = {
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
          # vadimcn.vscode-lldb
          waderyan.gitblame

          # linters, highlighters and formatters
          davidanson.vscode-markdownlint
          dbaeumer.vscode-eslint
          evgeniypeshkov.syntax-highlighter
          foxundermoon.shell-format
          jnoortheen.nix-ide
          ms-azuretools.vscode-docker
          ms-kubernetes-tools.vscode-kubernetes-tools
          ms-python.black-formatter
          open-southeners.laravel-pint
          redhat.vscode-yaml
          statiolake.vscode-rustfmt
          stylelint.vscode-stylelint
          vue.volar
          yzhang.markdown-all-in-one

          # PHP
          bmewburn.vscode-intelephense-client
          laravel.vscode-laravel
          onecentlin.laravel5-snippets
          # phpactor.vscode-phpactor
          # sanderronde.phpstan-vscode
          shufo.vscode-blade-formatter
          xdebug.php-debug
        ];

        keybindings = [
          # toggle sidebar and focus
          {
            "key" = "ctrl+e";
            "command" = "runCommands";
            "args" = {
              "commands" = [
                "workbench.action.toggleSidebarVisibility"
                "workbench.action.focusActiveEditorGroup"
              ];
            };
            "when" = "sideBarVisible";
          }
          {
            "key" = "ctrl+e";
            "command" = "runCommands";
            "args" = {
              "commands" = [
                "workbench.action.toggleSidebarVisibility"
                "workbench.action.focusSideBar"
              ];
            };
            "when" = "!sideBarVisible";
          }
          # always start a find and replace instead of a find in files session
          {
            "key" = "ctrl+shift+f";
            "command" = "workbench.action.replaceInFiles";
          }
          # todo-tree
          {
            "key" = "ctrl+shift+t";
            "command" = "todo-tree-view.focus";
          }
          # cline
          {
            "key" = "ctrl+shift+c";
            "command" = "claude-dev.SidebarProvider.focus";
          }
        ];

        userSettings = {
          "chat.editor.fontSize" = mkForce 14;
          "debug.console.fontSize" = mkForce 14;
          "editor.fontSize" = mkForce 14;
          "terminal.integrated.fontSize" = mkForce 14;

          "breadcrumbs.enabled" = false;
          "diffEditor.ignoreTrimWhitespace" = false;
          "diffEditor.renderSideBySide" = false;
          "editor.bracketPairColorization.enabled" = true;
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "explorer.confirmPasteNative" = false;
          "editor.cursorBlinking" = "smooth";
          "editor.cursorSmoothCaretAnimation" = "on";
          "editor.detectIndentation" = false;
          "editor.fontLigatures" = true;
          "editor.formatOnSave" = true;
          "editor.formatOnPaste" = false;
          "editor.guides.bracketPairs" = "active";
          "editor.insertSpaces" = true;
          "editor.inlineSuggest.enabled" = true;
          "editor.lineNumbers" = "relative";
          "editor.lineHeight" = 30;
          "editor.minimap.enabled" = false;
          "editor.scrollbar.horizontal" = "hidden";
          "editor.scrollbar.vertical" = "hidden";
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
          "outline.collapseItems" = "alwaysCollapse";
          "search.exclude" = {
            "**/public/" = true;
          };
          "search.useIgnoreFiles" = true;
          "window.customTitleBarVisibility" = "never";
          "window.menuBarVisibility" = "toggle";
          "window.titleBarStyle" = "native";
          "window.zoomLevel" = 0;
          "workbench.layoutControl.enabled" = false;
          "workbench.sideBar.location" = "right";
          "workbench.startupEditor" = "none";

          # blade
          "bladeFormatter.format.enabled" = true;
          "bladeFormatter.format.indentInnerHtml" = true;
          "bladeFormatter.format.indentSize" = 4;
          "bladeFormatter.format.noMultipleEmptyLines" = true;
          "bladeFormatter.format.noPhpSyntaxCheck" = false;
          "bladeFormatter.format.noSingleQuote" = false;
          "bladeFormatter.format.noTrailingCommaPhp" = false;
          "bladeFormatter.format.phpVersion" = "8.4";
          "bladeFormatter.format.sortHtmlAttributes" = "code-guide";
          "bladeFormatter.format.sortTailwindcssClasses" = true;
          "bladeFormatter.format.useTabs" = false;
          "bladeFormatter.format.wrapAttributes" = "force-expand-multiline";
          "bladeFormatter.format.wrapAttributesMinAttrs" = 2;
          "bladeFormatter.format.wrapLineLength" = 120;
          "bladeFormatter.misc.dontShowNewVersionMessage" = true;

          # css
          "stylelint.validate" = [
            "css"
            "scss"
          ];
          "tailwindCSS.emmetCompletions" = true;

          # emmet
          "emmet.includeLanguages" = {
            "blade" = "html";
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
            "wrapAttributes" = "force-expand-multiline";
          };

          # javascript
          "eslint.format.enable" = true;
          "eslint.validate" = [
            "javascript"
            "typescript"
            "javascriptreact"
            "typescriptreact"
          ];

          # nix
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nil";
          "nix.serverSettings" = {
            "nil" = {
              "formatting" = {
                "command" = [ "nixfmt" ];
              };
            };
          };

          # php
          "laravel-pint.enable" = true;
          "php.suggest.basic" = false; # intelephese
          "php.validate.enable" = false; # intelephense

          # telemetry
          "redhat.telemetry.enabled" = false;
          "telemetry.telemetryLevel" = "off";
          "update.mode" = "none";

          # todo tree
          "todo-tree.tree.autoRefresh" = true;
          "todo-tree.useBuiltInExcludes" = "search excludes";
          "todo-tree.highlights.customHighlight" = {
            "WARN" = {
              "foreground" = "#000";
              "background" = "#ffc386";
              "iconColour" = "#ffc386";
              "icon" = "alert";
            };
            "TODO" = {
              "foreground" = "#000";
              "background" = "#f4ff81";
              "iconColour" = "#f4ff81";
              "icon" = "check-circle";
            };
            "FIXME" = {
              "foreground" = "#000";
              "background" = "#ff7f7f";
              "iconColour" = "#ff7f7f";
              "icon" = "flame";
            };
          };
          "todo-tree.highlights.defaultHighlight" = {
            "type" = "text-and-comment";
          };
          "todo-tree.general.tags" = [
            "TODO"
            "WARN"
            "FIXME"
            "REVIEW"
          ];

          # formatting
          "[blade]" = {
            "editor.defaultFormatter" = "shufo.vscode-blade-formatter";
          };
          "[dockerfile]" = {
            "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
          };
          "[javascript][typescript][vue][javascriptreact][typescriptreact]" = {
            "editor.defaultFormatter" = "dbaeumer.vscode-eslint";
          };
          "[markdown]" = {
            "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
          };
          "[nix]" = {
            "editor.defaultFormatter" = "jnoortheen.nix-ide";
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
