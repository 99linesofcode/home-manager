# [0.15.0](https://github.com/99linesofcode/home-manager/compare/v0.14.0...v0.15.0) (2025-05-19)


### Features

* **hyprpicker:** module for colorpicking ([e69f8f1](https://github.com/99linesofcode/home-manager/commit/e69f8f11fc2095defd11fc3d097519a72d17897a))



# [0.14.0](https://github.com/99linesofcode/home-manager/compare/v0.13.0...v0.14.0) (2025-05-19)


### Bug Fixes

* **stylix:** style correct vscode profile instead of the default ([388a1af](https://github.com/99linesofcode/home-manager/commit/388a1af0eb38081b2bed3e50ff5fc6e1e43edef4))
* **vscode-neovim:** disable neovim configuration in vscode context ([f5698d2](https://github.com/99linesofcode/home-manager/commit/f5698d2bc99f30d33f493dbcb1a856ee6651e771))
* **vscode:** configure html formatter to force attributes on new line ([291e1de](https://github.com/99linesofcode/home-manager/commit/291e1de8d4bdb94ed5ceebdbb3021d892e2f8739))
* **vscode:** force font sizes as other windows do not inherit editor.fontSize ([bcaf221](https://github.com/99linesofcode/home-manager/commit/bcaf22141c08c2345a08f5d0383729cc2532ee71))
* **vscode:** ignore files in .gitignore on search by default ([cf49167](https://github.com/99linesofcode/home-manager/commit/cf4916778bee64b2b702a0ce6142f15a72d7f466))
* **vscode:** key remapping is handled at kernel level now ([d2c8c52](https://github.com/99linesofcode/home-manager/commit/d2c8c52fe83105916b8889c6f3b7d05dfa4a7421))
* **vscode:** read extensions from correct nixpkgs ([4f5ff2a](https://github.com/99linesofcode/home-manager/commit/4f5ff2a013861352da6b6f8f32875e5143c7f2d3))
* **vscode:** use html formatter for blade files since blade doesnt play nice with livewire ([517a3bf](https://github.com/99linesofcode/home-manager/commit/517a3bf5e3fc62b2793283dd9518c9db5a2f40c9))


### Features

* **firefox:** completely disable Pocket for added performance boost ([409b9dc](https://github.com/99linesofcode/home-manager/commit/409b9dc4022eae256ec34dc22f3b33f046fe08e1))
* **firefox:** declare default application ([f015b83](https://github.com/99linesofcode/home-manager/commit/f015b83fc03d6554115a64b8b5bad3186fbb5e27))
* **nvim-lsp:** intelephense instead of phpactor as lsp ([add025c](https://github.com/99linesofcode/home-manager/commit/add025c99f9721ab2220dd6b1d55d92f6f13cd66))
* **steam:** replace protonup with steamtinkerlaunch ([80e9696](https://github.com/99linesofcode/home-manager/commit/80e96962e0decf6eb00e0ba9e09b709856c460b7))
* **vscode:** keybinds for todo tree and cline ([6fae63a](https://github.com/99linesofcode/home-manager/commit/6fae63ac529a8e44373b57227c8957a48f6475af))
* **vscode:** removed unnecessary UI element cluttering up the workspace ([08eeee4](https://github.com/99linesofcode/home-manager/commit/08eeee4f1a50d3bbae297b72c2bc48d204da4077))
* **vscode:** toggle and focus sidebar ([9e6bc71](https://github.com/99linesofcode/home-manager/commit/9e6bc714e7945ba6a4174a466c4bfb382da627c0))



# [0.13.0](https://github.com/99linesofcode/home-manager/compare/v0.12.0...v0.13.0) (2025-04-14)


### Bug Fixes

* **mpv:** no need to manually define yazi opener rules ([c88eb1d](https://github.com/99linesofcode/home-manager/commit/c88eb1d16b82ea718032084efaa51551575fb46e))
* **obsidian:** timer was not registered correctly ([5688cfb](https://github.com/99linesofcode/home-manager/commit/5688cfb9332826a2b2d7e4c3729889c4c1c55b07))


### Features

* allow declaring default mime type associations ([5f4e30b](https://github.com/99linesofcode/home-manager/commit/5f4e30bfdfe1c7374388884a86057f72b87e43a3))
* **feh:** declare default application for common mimetypes ([6a17a0b](https://github.com/99linesofcode/home-manager/commit/6a17a0b3cc3920c2a9e442c5b6c2a2542f22f41a))
* **firefox:** custom search engine for the ArchLinux wiki ([23ac9da](https://github.com/99linesofcode/home-manager/commit/23ac9da2bf67524ebbe8a376f642e7df9bae7723))
* **gammastep:** automatically adjust color temperature ([c614d5b](https://github.com/99linesofcode/home-manager/commit/c614d5b890fd7108fad6bc5857c70ef02347d86e))
* **hypridle:** reduce brightness, lock, turn off screen, suspend ([5ab1c16](https://github.com/99linesofcode/home-manager/commit/5ab1c165d408bde9f98df5bd56b74ca3370420ca))
* **hyprlock:** display date and time on lock screen ([4ece5ab](https://github.com/99linesofcode/home-manager/commit/4ece5ab77e8d3aa470745406424df747e5725591))
* **hyprpaper:** load a random wallpaper every 30 minutes ([4056f80](https://github.com/99linesofcode/home-manager/commit/4056f80ec7b78642367f9e82c73d1bd9a988c7ab))
* **zathura:** declare default application for common mimetypes ([7a3d45a](https://github.com/99linesofcode/home-manager/commit/7a3d45a02f81ed433b64ccddafb31cd8ecb4a750))



# [0.12.0](https://github.com/99linesofcode/home-manager/compare/v0.11.0...v0.12.0) (2025-04-10)


### Bug Fixes

* disable rustdesk and vscode as they fail to build atm ([dac424f](https://github.com/99linesofcode/home-manager/commit/dac424f80fea665f60c1de052e096ec79786127f))
* **zellij:** disable startup tips ([92e9fa4](https://github.com/99linesofcode/home-manager/commit/92e9fa42cd032cfdda94f6dcd8c60f245eecaa5a))


### Features

* **mpv:** configure yazi open rules if yazi is enabled ([d0e308b](https://github.com/99linesofcode/home-manager/commit/d0e308b90d975b28fb6a36d7da8df4634aa4d4ea))
* **ssh:** configure agent forwarding and keep alive where relevant ([8e97416](https://github.com/99linesofcode/home-manager/commit/8e97416f772b9bd5cb0ba88031c324d026d189bc))
* **yazi:** sensible default configuration ([d350b1a](https://github.com/99linesofcode/home-manager/commit/d350b1aa9121634b5f853e4051016a152beb3efd))
* **zsh:** start hyprland through uwsm on profile load ([74496e2](https://github.com/99linesofcode/home-manager/commit/74496e21c49dd3a9be4dd101bfa8b12ee8ef47b0))



# [0.11.0](https://github.com/99linesofcode/home-manager/compare/v0.10.0...v0.11.0) (2025-03-20)


### Bug Fixes

* **clipboard:** not working due to unset WAYLAND_DISPLAY env variable ([16f97d7](https://github.com/99linesofcode/home-manager/commit/16f97d7f73f0decfb92584daf23807f1d6b67fa7))
* **hyprland:** enable graphical polkit authentication agent ([28a349d](https://github.com/99linesofcode/home-manager/commit/28a349daefc27e47ec27a08590295a7ca64e8580))
* **obsidian:** prevent halting on large vault updates ([272dc7f](https://github.com/99linesofcode/home-manager/commit/272dc7ff2087a505cba118646e1fd0a67f59d1a2))
* **obsidian:** service shouldn't depend on or be wanted by anything ([4374a85](https://github.com/99linesofcode/home-manager/commit/4374a857a745d2ed6f61d2f972ee8b09e277367a))


### Features

* **obsidian:** bi-directional synchronization of Obsidian.md vault ([a7bbdfc](https://github.com/99linesofcode/home-manager/commit/a7bbdfc4d3750ecab4e49aacdcbd7611d58fb71a))



