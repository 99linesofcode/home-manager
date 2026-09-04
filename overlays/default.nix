{ inputs, ... }: {
  unstable-packages = final: _: {
    nix-unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };

    hm-unstable = import inputs.home-manager-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
