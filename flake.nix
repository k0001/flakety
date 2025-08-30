{
  description = "Overrides to upstream nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/a84dbbecc82aa208f11a16d37ed27996af3b477e";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      flake.overlays.default = (
        final: prev:
        let
          hsLib = prev.haskell.lib;
          hsClean =
            drv:
            hsLib.overrideCabal drv (old: {
              src = prev.lib.sources.cleanSource old.src;
            });
        in
        {
          haskell = prev.haskell // {
            packageOverrides = prev.lib.composeExtensions (prev.haskell.packageOverrides or (_: _: { })) (
              hself: hsuper:
              prev.lib.optionalAttrs (prev.lib.versions.majorMinor hsuper.ghc.version == "9.12") {
                Diff = hsuper.Diff_1_0_2;
                skeletest = hsLib.markUnbroken hsuper.skeletest;
                web-view = # tests fail because of some missing files
                  hsLib.markUnbroken (hsLib.dontCheck (hsLib.doJailbreak hsuper.web-view));
                pipes-safe = hsLib.doJailbreak hsuper.pipes-safe;
                data-default = hsuper.data-default_0_8_0_1;
                tls = hself.callHackage "tls" "2.1.6" { };
                hoogle = hsLib.doJailbreak ( hself.callHackage "hoogle" "5.0.18.4" { });
              }
            );
          };
        }
      );
      systems = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
      ];
      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.self.overlays.default ];
          };
        };
    };
}
