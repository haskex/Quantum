{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mkOption types mkEnableOption;
in {
  options.np = {
    defaultPackages = mkEnableOption {
      description = "Install default lib packages";
      default = false;
    };

    unfree = mkEnableOption {
      description = "Allow Unfree packages";
      default = true;
    };

    packages = mkOption {
      type = types.listOf types.package;
      description = "A list of packages";
      default = [];
    };

    overlays = {
      enable = mkEnableOption {
        description = "Use overlays on nixos configuration";
        default = false;
      };

      paths = mkOption {
        type = types.listOf types.path;
        default = [];
        description = "Overlays paths";
      };
    };
  };

  config = mkMerge [
    (mkIf (config.np.unfree) {
      nixpkgs.config.allowUnfree = true;
    })

    (mkIf (config.np.overlays.enable) {
      nixpkgs.overlays = map import config.np.overlays.paths;
    })

    (mkIf (config.np.defaultPackages) {
      environment.systemPackages = with pkgs;
        config.np.packages
        ++ [
          bluez
          libnotify
          pulseaudio
          nodejs
          unzip
          sqlite
          home-manager
          wget

          # LSPs
            # Nix
              nil
              alejandra

            # Haskell
              ghc
              haskellPackages.haskell-language-server
              stack

            # Lisp is life!!!
              sbcl
        ];
    })

    (mkIf (!config.np.defaultPackages) {
      environment.systemPackages = config.np.packages;
    })
  ];
}
