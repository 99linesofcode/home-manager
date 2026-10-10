# [0.24.0](https://github.com/99linesofcode/home-manager/compare/v0.23.0...v0.24.0) (2026-10-10)


### Features

* **opencode:** more convention over configuration, rails, concurrent memory ([00ef999](https://github.com/99linesofcode/home-manager/commit/00ef9991ad4ee088390ea3a6a56f4b16b2bcb51a))



# [0.23.0](https://github.com/99linesofcode/home-manager/compare/v0.22.1...v0.23.0) (2026-10-10)


### Features

* add docker and kubernetes skills ([af0b83c](https://github.com/99linesofcode/home-manager/commit/af0b83caa8dab394988b543356839633a7097587))
* **gc:** run garbage collection on user profiles ([2a3f0cf](https://github.com/99linesofcode/home-manager/commit/2a3f0cf8de37e319ccc14178ed63ecbe6af46ca2))
* **obsidian:** add oneshot service to allow for forced resynchronization without safety checks ([bf7d4c2](https://github.com/99linesofcode/home-manager/commit/bf7d4c2df87848c4ba69f4e973e0633314a6ca2b))
* **opencode:** dramatic improvement in spec-driven development adherence ([15882d0](https://github.com/99linesofcode/home-manager/commit/15882d08110a0eb32839de46dcd7c8666415b04b))



## [0.22.1](https://github.com/99linesofcode/home-manager/compare/v0.22.0...v0.22.1) (2026-10-09)


### Bug Fixes

* **ci:** pass repo secrets to the update-agent job ([#38](https://github.com/99linesofcode/home-manager/issues/38)) ([7c78b2f](https://github.com/99linesofcode/home-manager/commit/7c78b2f9c3b6803aec5554c3a5106fb9d2a5c5cf))



# [0.22.0](https://github.com/99linesofcode/home-manager/compare/v0.21.0...v0.22.0) (2026-09-06)


### Bug Fixes

* **github:** remove nested .github directory ([c8eb337](https://github.com/99linesofcode/home-manager/commit/c8eb33776819845fda9cbda268c014bd415381ec))
* **nvim:** enable autoread so the editor picks up on ACP server changes ([fa9767a](https://github.com/99linesofcode/home-manager/commit/fa9767a763a1cdb85178a8eaed9aeb26a253431f))
* **obs:** correctly set QT_QPA_PLATFORM and optionally enable wlroots plugin ([d8cae84](https://github.com/99linesofcode/home-manager/commit/d8cae84f5fa0edb265d3820762c408329a8b8a91))
* **obsidian:** only run activation script on first run ([55b0aaa](https://github.com/99linesofcode/home-manager/commit/55b0aaab404463325512e987c64ca5797bf3989a))
* **opencode:** enable EXA for websearch ([15dc4ab](https://github.com/99linesofcode/home-manager/commit/15dc4ab94ca211e414551750dd293ca29171099c))
* **opencode:** set permissive permissions but lock down filesystem and set bash to ask ([1b2fe46](https://github.com/99linesofcode/home-manager/commit/1b2fe46d97353a1ff0a0a4a800bdf05212394901))
* **sops:** look for secrets in the derivation output path to avoid impure errors ([dad6179](https://github.com/99linesofcode/home-manager/commit/dad617930d56be25e88f1ee7680a940a5e4ee9e4))
* **typst:** use unstable as that has support for variable font sizes ([cfbe24a](https://github.com/99linesofcode/home-manager/commit/cfbe24a96a56b10daf809921dc5f4e04cba58db4))
* **voxtype:** use toggle instead of press and hold ([51e5ec1](https://github.com/99linesofcode/home-manager/commit/51e5ec12141ba4413be14ecfa9c2e07eb1d2e1f0))


### Features

* **discord:** added Discord MCP server ([e943760](https://github.com/99linesofcode/home-manager/commit/e943760ad0e3bd6ca038ca7026ccf16afc8e0811))
* **firefox:** allow converting web content to markdown files using obsidian web clipper ([e15ef03](https://github.com/99linesofcode/home-manager/commit/e15ef037273294648b7a2ab1be6a9811ecadc2a3))
* **git:** added GitHub MCP server ([bb27720](https://github.com/99linesofcode/home-manager/commit/bb27720088db51d4c4cc4de73899e88039679246))
* **obsidian:** add support for the MCP protocl using seekstone ([0a9897b](https://github.com/99linesofcode/home-manager/commit/0a9897b3a724c5e23afb20614395029d388bf873))
* **opencode:** enable MCP for Google Workspace and Todoist ([0ff02d3](https://github.com/99linesofcode/home-manager/commit/0ff02d31a3ce910ebec4216ee7e9c73233dc0218))
* **opencode:** expand SKILLs catalog ([1374db4](https://github.com/99linesofcode/home-manager/commit/1374db42715e0d69fcb7bed0df6ed6b103768843))
* **opencode:** full user access but disable destructive operations ([11a5e3e](https://github.com/99linesofcode/home-manager/commit/11a5e3eff9307b9d24cfdc08c175e64d5ae8bf11))
* **opencode:** read global agents/ and skills/ from home-manager/.opencode directory ([5d0d38f](https://github.com/99linesofcode/home-manager/commit/5d0d38f8c872959af04ce5c2d398a2b4d1ab67b1))
* **opencode:** scaffold module and default to deepseek v4 for now ([7967796](https://github.com/99linesofcode/home-manager/commit/7967796278775779addea6018cfd8c46d0c20e57))
* **openssh:** enable services.ssh-agent so $SSH_AUTH_SOCK is always available ([cb614a9](https://github.com/99linesofcode/home-manager/commit/cb614a9e62f2d0287de463c7da9baab650ae7201))
* **voxtype:** enable meeting mode ([7dcdc0b](https://github.com/99linesofcode/home-manager/commit/7dcdc0bcc1a1fb4d725c35ee78a6d8ba5db79bf7))
* **voxtype:** enable waybar status indicator ([edc5336](https://github.com/99linesofcode/home-manager/commit/edc5336ac4b8cb55bc6dc3b98e98602873c511ad))
* **voxtype:** max recording duration is now set to 5 minutes ([82168ab](https://github.com/99linesofcode/home-manager/commit/82168ab4dae3e655da59a92667795ef1a628ac52))
* **voxtype:** Voice-to-text with push-to-talk for Wayland compositors ([5801737](https://github.com/99linesofcode/home-manager/commit/580173705e4c3e8e1a326ea73df738cef1c16587))
* **zed:** scaffold module for Zed, the GPU accelerated text editor ([0014fb0](https://github.com/99linesofcode/home-manager/commit/0014fb02b1df2e925e9675b497cf96a958fd7beb))



# [0.21.0](https://github.com/99linesofcode/home-manager/compare/v0.20.2...v0.21.0) (2026-07-06)


### Bug Fixes

* **hyprpaper:** hyprctl hyprpaper was called incorrectly ([d2dca52](https://github.com/99linesofcode/home-manager/commit/d2dca52f8a73053967e43dcf32b466eada3092b4))
* **obs:** write input-overlay presets in .config/obs-studio ([088f807](https://github.com/99linesofcode/home-manager/commit/088f80750b7f78a0f4905a22b9f1d8e17a53d676))
* **sops:** defaultSopsFile should point to a secrets file, not the .sops config ([49430a6](https://github.com/99linesofcode/home-manager/commit/49430a6602f1321d04a26b7a4904874cfee921a7))
* **sops:** master key decrypts everything and hosts don't need access to hm secrets ([9b26fa7](https://github.com/99linesofcode/home-manager/commit/9b26fa753143c1c79530b420a65a1eef551fb064))
* **sops:** use ${username}.txt age key and generate it if it doesn't exist ([4595b46](https://github.com/99linesofcode/home-manager/commit/4595b460954763649da7f7cb7ef0136e6f4fbc3e))
* use dedicated release versions for other flakes as well ([03d522d](https://github.com/99linesofcode/home-manager/commit/03d522d9ac1231c0d1ce6393b5d26198a2d8dad1))


### Features

* **bitwarden:** replace desktop with CLI ([c67695a](https://github.com/99linesofcode/home-manager/commit/c67695af3b2c9253e9a7c6a6d1eda7b4a468deaa))
* **obsidian:** run bisync --resync on initial run ([60aac98](https://github.com/99linesofcode/home-manager/commit/60aac9810e19a3083c6c9fb84ceaba83fa1abd7f))
* **rclone:** define files that can optionally be ignored ([d5881f7](https://github.com/99linesofcode/home-manager/commit/d5881f7a57f016b277770cf4ab92188f9df927f6))
* **syncthing:** add fairphone device ID ([410ca48](https://github.com/99linesofcode/home-manager/commit/410ca4813798f858d13776456c88fe2a2a2ece8d))
* **typst:** convert .md files to PDFs using Pandoc and Typst ([44e9c71](https://github.com/99linesofcode/home-manager/commit/44e9c71384646f48f7b40640cb60550bce3a118d))



