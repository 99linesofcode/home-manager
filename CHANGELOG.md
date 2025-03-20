# [0.11.0](https://github.com/99linesofcode/home-manager/compare/v0.10.0...v0.11.0) (2025-03-20)


### Bug Fixes

* **clipboard:** not working due to unset WAYLAND_DISPLAY env variable ([16f97d7](https://github.com/99linesofcode/home-manager/commit/16f97d7f73f0decfb92584daf23807f1d6b67fa7))
* **hyprland:** enable graphical polkit authentication agent ([28a349d](https://github.com/99linesofcode/home-manager/commit/28a349daefc27e47ec27a08590295a7ca64e8580))
* **obsidian:** prevent halting on large vault updates ([272dc7f](https://github.com/99linesofcode/home-manager/commit/272dc7ff2087a505cba118646e1fd0a67f59d1a2))
* **obsidian:** service shouldn't depend on or be wanted by anything ([4374a85](https://github.com/99linesofcode/home-manager/commit/4374a857a745d2ed6f61d2f972ee8b09e277367a))


### Features

* **obsidian:** bi-directional synchronization of Obsidian.md vault ([a7bbdfc](https://github.com/99linesofcode/home-manager/commit/a7bbdfc4d3750ecab4e49aacdcbd7611d58fb71a))



# [0.10.0](https://github.com/99linesofcode/home-manager/compare/v0.9.0...v0.10.0) (2025-03-20)


### Bug Fixes

* **vscode:** re-enable remote development pack ([6db3c3b](https://github.com/99linesofcode/home-manager/commit/6db3c3b259c6df4e1f9eed0953ae45900729e63d))


### Features

* **conform.nvim:** add formatting for POSIX shell scripts ([85490d7](https://github.com/99linesofcode/home-manager/commit/85490d7a6695a5d4d76ba1317794bcca324e0053))
* **conform.nvim:** add formatting for Rust and C/C++ ([583e6d2](https://github.com/99linesofcode/home-manager/commit/583e6d230d5cdb0105e04310761503c7944734ad))
* **nvim-dap:** debugging C/C++/Rust with vscode-lldb ([140bb2a](https://github.com/99linesofcode/home-manager/commit/140bb2a033d8b2126120254fb37fc98890ef9587))
* **vscode:** blade template formatting using blade-formatter ([e4027d9](https://github.com/99linesofcode/home-manager/commit/e4027d91b5c5b8f7baf5cf150b608bd6ac6daf1b))
* **vscode:** python formatting using black ([1f83047](https://github.com/99linesofcode/home-manager/commit/1f830477aa5c9414f5157429894a6f4759dc1cdf))
* **vscode:** rust formatting using rustfmt ([c1c60aa](https://github.com/99linesofcode/home-manager/commit/c1c60aafddf236efd9ba4aa88a8835d29332dd3f))
* **vscode:** support for step debugging of compiled languages ([7aae192](https://github.com/99linesofcode/home-manager/commit/7aae1925e5b49acf57648255ccb7e4947418f5b4))



# [0.9.0](https://github.com/99linesofcode/home-manager/compare/v0.8.0...v0.9.0) (2025-03-17)


### Bug Fixes

* **firefox:** automatically enable newly installed extensions ([f11b306](https://github.com/99linesofcode/home-manager/commit/f11b3062ef6a9cadd6499c2817cf96ccac020c74))
* **firefox:** hide bookmark bar by default ([76c54eb](https://github.com/99linesofcode/home-manager/commit/76c54eb6a94b0e8ee120bafe121559a7ffb3a49d))
* **hyprland:** Prefix application startup commands with uwsm app -- ([fa4243a](https://github.com/99linesofcode/home-manager/commit/fa4243a8cb9713b07c9cf2bcafcc244064644595))
* incorrect formatter definition ([5b2918f](https://github.com/99linesofcode/home-manager/commit/5b2918f0561bfe59a0c83478c196a6e4c65c2be8))
* **mpv:** stylix will handle font definition based on theme ([f24879d](https://github.com/99linesofcode/home-manager/commit/f24879d73038babedda9df71200ed05e52f8c62e))
* **zsh:** fixed an issue where starting hyprland on login caused system freezes ([f84dc9b](https://github.com/99linesofcode/home-manager/commit/f84dc9b3d3b72adc0dab49f7467b2622b2deff7b))


### Features

* **bluetui:** TUI for managing bluetooth connections ([047130b](https://github.com/99linesofcode/home-manager/commit/047130b22905a1988dfe8f55483565abd41fd6d9))
* **conform.nvim:** blade formatting with blade-formatter and eslint/prettier fallback ([4a71660](https://github.com/99linesofcode/home-manager/commit/4a716604160b4b742a9c377ca993435439809f93))
* **conform.nvim:** HTML formatting with superhtml, with eslint and prettier fallback ([064e845](https://github.com/99linesofcode/home-manager/commit/064e8459b3eaac56911df9279132858918b760b0))
* **conform.nvim:** javascript/typescript formatting with eslint_d and fallbacks ([91b83ed](https://github.com/99linesofcode/home-manager/commit/91b83edea38293e273ed4fad6c18b14630f1b67a))
* **conform.nvim:** markdown formatting with markdownlint-cli2 ([3606f5b](https://github.com/99linesofcode/home-manager/commit/3606f5be96916b2632e1e401520168e83cf4ef48))
* **conform.nvim:** PHP formatting with laravel/pint and php-cs-fixer ([1b312f6](https://github.com/99linesofcode/home-manager/commit/1b312f673f34f35ab0a89afa5b478280afccc62e))
* **dap.nvim:** enable debug adapter protocol for PHP ([f978924](https://github.com/99linesofcode/home-manager/commit/f978924b316dbe8732a36e5ae3a134081fbbb973))
* **eza:** modern alternative to ls ([4024a16](https://github.com/99linesofcode/home-manager/commit/4024a16763fa9a81ed1bce64985d0a029789baa5))
* **firefox:** added Read Aloud TTS voice reader ([ff27412](https://github.com/99linesofcode/home-manager/commit/ff27412657bf1394154a3ce335942772a04883d3))
* **firefox:** added Rotten Tomatoes search engine [@rt](https://github.com/rt) ([f79462a](https://github.com/99linesofcode/home-manager/commit/f79462aee04531b585676dc33fffe2e671b015c5))
* **firefox:** declarative policy definitions ([8ec5c12](https://github.com/99linesofcode/home-manager/commit/8ec5c1222d6acdf74f65bfa05d11fcd06f474db6))
* **firefox:** hardware video acceleration with nvidia-vaapi-driver ([51057ca](https://github.com/99linesofcode/home-manager/commit/51057cae10b2075a0dcf2c5c0ba310d077b69789))
* **nvim-dap:** debugging PHP with vscode-php-debug ([524ea6c](https://github.com/99linesofcode/home-manager/commit/524ea6cfebcda5483e84ee3cbe44565420eeb0bd))
* **zsh:** enable syntax highlighting ([e468103](https://github.com/99linesofcode/home-manager/commit/e468103f8c753cba6e5aa239c4fd095b2af7cb0d))



# [0.8.0](https://github.com/99linesofcode/home-manager/compare/v0.7.1...v0.8.0) (2025-03-03)


### Bug Fixes

* **bluetooth:** awk uses single instead of double quotes ([e020150](https://github.com/99linesofcode/home-manager/commit/e020150c790fd015285989cd290007c3b5d3e4cf))
* **bluetooth:** put shell script in systemd.slice ([acd98f5](https://github.com/99linesofcode/home-manager/commit/acd98f5929cc9839030e84aed8f871b71ef21b71))
* **brightnessctl:** throwing non-existent XF86Kbd keycodes errors ([b21bed7](https://github.com/99linesofcode/home-manager/commit/b21bed7453453cf2d27b7fc227f646ce7971f781))
* **firefox:** addons moved to extensions.packages ([424ee4b](https://github.com/99linesofcode/home-manager/commit/424ee4b9c1ef21eb28085b43b960161b08abf5b2))
* **firefox:** broken NixOS wiki search engine ([e8fa113](https://github.com/99linesofcode/home-manager/commit/e8fa11371ff56b1e1a80d9217d79168d37d40df0))
* **nvim:** display notifications for a second longer ([062b07b](https://github.com/99linesofcode/home-manager/commit/062b07b073105cbdf7a3f277be7bba68354ddee3))
* suppressed home-manager news notification ([56046e1](https://github.com/99linesofcode/home-manager/commit/56046e1759c6106011a8f50cef8e3dce9187546a))
* **vscode:** extensions moved to profiles.default.extensions ([cb71cbb](https://github.com/99linesofcode/home-manager/commit/cb71cbb3bb247c8086af6c83fbe2a113b0d4c498))


### Features

* **nvim:** markdown formatting in codecompanion chat buffer ([b428999](https://github.com/99linesofcode/home-manager/commit/b4289995731898894c910efd6107cc78d5ba0319))



## [0.7.1](https://github.com/99linesofcode/home-manager/compare/v0.7.0...v0.7.1) (2025-02-22)


### Bug Fixes

* **vscode:** missing homeManager module import ([fd579fb](https://github.com/99linesofcode/home-manager/commit/fd579fbe2af18c4f98372c309fe148c33988d9f3))



