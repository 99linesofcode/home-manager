# Home-Manager

My flake based standalone [home-manager](https://nix-community.github.io/home-manager/) configuration. While I run NixOS on all of my systems I prefer using Home Manager so it can be used irrespective of the Linux operating system.

## How to Use

Home-manager is a Nix powered tool and while knowledge of [Nix](https://nix.dev), the [Nix Module System](https://nix.dev/tutorials/module-system/) and [Nix Flakes](https://nix.dev/concepts/flakes) will make your life a lot easier, I've set up this repository in such a way that you should be able to get up and running in no time. I've made a conscious effort to stay away from libraries such as [flake-utils](https://github.com/numtide/flake-utils) to keep things simple and remain as close to the Nix language as possible.

To start using this repository to manage your own dotfiles with Nix, there are only a couple of things you need to do:

1. Make sure that your system has both Nix and Home Manager installed;
1. Define a `HomeConfiguration` for your host and user;
1. Add a custom user configuration under `hosts/`;
1. Configure your user and enable any Nix Modules found in `modules/` that you would like to use;
1. Add encrypted secrets if you are using any modules that depend on [SOPS](https://github.com/getsops/sops);
1. Activate your configuration.

#### Defining a `HomeConfiguration`

The `HomeConfiguration` function is defined in `flake.nix`. `Outputs` returns an attribute set with `homeConfigurations` containing one or more `HomeConfiguration`. Below you can find an example of the one I use for the host `luna` and username `shorty`:

https://github.com/99linesofcode/home-manager/blob/50fff4aeadfcc5a513a75e7e49599a625559c635/flake.nix#L58-L66

The `hostname`, `username` and `role` arguments passed as `extraSpecialArgs` are used to determine which `hosts/{hostname}/role/{role}/` and `hosts/{hostname}/users/{username}/` configuration will get used.

#### Add a user configuration

The `HomeConfiguration` function automatically imports `hosts/`. `default.nix` is used as a default file when importing directories:

https://github.com/99linesofcode/home-manager/blob/50fff4aeadfcc5a513a75e7e49599a625559c635/hosts/default.nix#L16-L23

As you can see this file imports the `shared/` and the `hosts/{hostname}/` directories which in turn contain their own `default.nix` files with their own import logic. Every one of these files is in and of itself nothing but a simple Nix module.

### Configure your user and enable Nix modules

Reusable modules that have already been built live in the `modules/` directory. Most of them are pretty straightforward and consist of a simple `mkEnableOption` and the relevant module `config`. Let's look at a simple example:

https://github.com/99linesofcode/home-manager/blob/50fff4aeadfcc5a513a75e7e49599a625559c635/modules/dunst.nix#L1-L23

Enabling this module is as easy as adding `home.dunst.enable = true;` to your user's configuration. Take a look at [hosts/luna/users/shorty/default.nix](https://github.com/99linesofcode/home-manager/blob/50fff4aeadfcc5a513a75e7e49599a625559c635/hosts/luna/users/shorty/default.nix) for a complete example.

#### Encrypted secrets

Secrets such as your SSH keys, configuration files containing authentication tokens or anything else you might want to hide from the outside world and restrict access to are encrypted and managed through SOPS. Decrypting, storing and using them within Nix is done through https://github.com/Mic92/sops-nix.

The `.sops.yaml` file configures the public keys that will be used to encrypt files in certain directories:

https://github.com/99linesofcode/home-manager/blob/50fff4aeadfcc5a513a75e7e49599a625559c635/.sops.yaml#L2-L20

As you can see I've configured both the `master` and `luna_shorty` keys to be able to encrypt (and decrypt) files under `hosts/shared/secrets/`, `hosts/luna/secrets/` and `hosts/luna/users/{username}/secrets/`.

Everytime you use sops to create a file inside one of these directories they will automatically be encrypted with the referenced public keys. Either private key corresponding to one of the public keys can then be used to decrypt the file. Be sure to check out the SOPS repository to learn more.

Now that we've encrypted our secrets, the last step is to learn how to use them inside your Nix modules. SOPS supports a variety of formats but here is an example of how to import a binary file and expose it to your Nix module using the already built in `sops-nix` library:

https://github.com/99linesofcode/home-manager/blob/50fff4aeadfcc5a513a75e7e49599a625559c635/modules/rclone.nix#L21-L28

When switching to your new configuration, `sops-nix` will use `sops` to decrypt the file using the private key stored in `$XDG_CONFIG_HOME/sops/age/keys.txt` and make it available under `XDG_RUNTIME_DIR/secrets.d` and, in this case, create a symlink to that file under `$HOME/.config/rclone/rclone.conf;`. 

#### Activate your configuration

Congratulations, you should now have all the pieces to cobble together your own - declaractive - Linux environment using Nix and Home Manager! Once you're ready to check out your work, simply run the following command and enjoy:

`home-manager switch --flake .#{homeConfigAttributeName}` where `{homeConfigAttributeName}` is something like `luna.shorty` in my examples.

## Work In Progress

I've only just started along this journey of Nix myself and there are still quite a few bits and bobs that are missing or a little rough around the edges. For example, some programs might not be bundled with the right module. I'm sure I'll get around to it some day but please be aware that you might run into some issues along the way. If you do, please [create a new issue](https://github.com/99linesofcode/home-manager/issues/new/choose) and I'd be happy to help you sort 'em out.

## Contributing

Please review our [Contribution Guidelines](https://github.com/99linesofcode/.github/blob/main/.github/CONTRIBUTING.md).

## Code of Conduct

In order to ensure that the community is welcoming to all, please review and abide by the [Code of Conduct](https://github.com/99linesofcode/.github?tab=coc-ov-file).

## Security Vulnerabilities

Please review [our security policy](https://github.com/99linesofcode/.github?tab=security-ov-file) on how to report security vulnerabilities.

## License

This software is open source and licensed under the [MIT license](https://github.com/99linesofcode/.github?tab=MIT-1-ov-file)
