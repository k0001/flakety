{
  description = "Overrides to upstream nixpkgs";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/933d7dc155096e7575d207be6fb7792bc9f34f6d";
    flake-parts.url = "github:hercules-ci/flake-parts";

    hourglass = {
      url = "github:k0001/hs-hourglass";
      flake = false;
    };

    singletons_3_2 = {
      url = "github:goldfirere/singletons/singletons-th-base-3.2";
      flake = false;
    };

    smtp-mail = {
      url =
        "github:MasterWordServices/smtp-mail/4c724c80814ab1da7c37256a6c10e04c88b9af95";
      flake = false;
    };

    safe = {
      url = "github:ndmitchell/safe/v0.3.21";
      flake = false;
    };

    hoogle = {
      url = "github:ndmitchell/hoogle/v5.0.18.4";
      flake = false;
    };

    cborg = {
      url = "github:well-typed/cborg";
      flake = false;
    };

    streaming-utils = {
      url =
        "github:k0001/streaming-utils/b7acc4dd0bf4ed6fb16fd4f4999bec24dfabceb3";
      flake = false;
    };

  };

  outputs = inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      flake.overlays.default = (final: prev:
        let
          hsLib = prev.haskell.lib;
          hsClean = drv:
            hsLib.overrideCabal drv
            (old: { src = prev.lib.sources.cleanSource old.src; });
        in {
          haskell = prev.haskell // {
            packageOverrides = prev.lib.composeExtensions
              (prev.haskell.packageOverrides or (_: _: { })) (hself: hsuper:
                prev.lib.optionalAttrs
                (prev.lib.versions.majorMinor hsuper.ghc.version == "9.6") {
                  # Extra features.
                  resourcet = hself.resourcet_1_3_0;

                  singletons-base = hself.callCabal2nix "singletons-base"
                    "${inputs.singletons_3_2}/singletons-base" { };
                  singletons-th = hself.callCabal2nix "singletons-th"
                    "${inputs.singletons_3_2}/singletons-th" { };
                  th-desugar = hself.callHackage "th-desugar" "1.15" { };

                  # Required by 'warp-tls'
                  tls = hself.tls_1_9_0;

                  # Required by 'warp-tls'. Tests disabled because of sandbox constraints.
                  warp = hsLib.dontCheck hself.warp_3_3_30;

                  # Required by 'hoogle'.
                  warp-tls = hself.warp-tls_3_4_3;

                  # For compatiblity with 'crypton-connection'
                  http-client-tls = hself.http-client-tls_0_3_6_3;
                  hoogle = hself.callCabal2nix "hoogle" inputs.hoogle { };

                } // prev.lib.optionalAttrs
                (prev.lib.versions.majorMinor hsuper.ghc.version == "9.8") {
                  # Extra features.
                  resourcet = hself.resourcet_1_3_0;
                  pipes-safe = hsLib.doJailbreak
                    (hself.callHackage "pipes-safe" "2.3.5" { });

                  ## Requiered updates:
                  megaparsec = hself.megaparsec_9_6_1;
                  postgresql-simple =
                    hsLib.doJailbreak (hself.postgresql-simple_0_7_0_0);
                  postgresql-libpq =
                    hsLib.doJailbreak (hself.postgresql-libpq_0_10_0_0);

                  # broken
                  streaming-conduit = hsLib.doJailbreak
                    (hsLib.markUnbroken hsuper.streaming-conduit);
                  cassava-conduit = hsLib.doJailbreak
                    (hsLib.markUnbroken hsuper.cassava-conduit);
                  hspec-api = hsLib.markUnbroken hsuper.hspec-api;

                  # Tests don't compile
                  lifted-base = hsLib.dontCheck hsuper.lifted-base;

                  # Tests don't compile, compatibility with GHC 9.8
                  bsb-http-chunked =
                    hsLib.doJailbreak (hsLib.dontCheck hsuper.bsb-http-chunked);

                  # For compatibility with 'th-abstraction'
                  bifunctors = hself.bifunctors_5_6_1;
                  aeson = hself.aeson_2_2_1_0;
                  free = hself.free_5_2;

                  # For compatibility with 'aeson'
                  hpack = hself.hpack_0_36_0;
                  aeson-pretty = hself.aeson-pretty_0_8_10;
                  attoparsec-aeson = hself.attoparsec-aeson_2_2_0_1;
                  http-conduit = hself.http-conduit_2_3_8_3;
                  streaming-utils =
                    hself.callCabal2nix "streaming-utils" inputs.streaming-utils
                    { };

                  # For compatibility with 'time'
                  hourglass =
                    hself.callCabal2nix "hourglass" inputs.hourglass { };

                  # For compatibility with GHC 9.8
                  attoparsec-iso8601 = hself.attoparsec-iso8601_1_1_0_1;
                  doctest = hself.doctest_0_22_2;
                  fgl = hsLib.doJailbreak hself.fgl_5_8_2_0;
                  generic-lens-core =
                    hsLib.doJailbreak hsuper.generic-lens-core;
                  generic-monoid = hsLib.doJailbreak hsuper.generic-monoid;
                  hedgehog = hself.hedgehog_1_4;
                  hspec = hself.hspec_2_11_7;
                  hspec-core = hself.hspec-core_2_11_7;
                  hspec-discover = hself.hspec-discover_2_11_7;
                  hspec-meta = hself.hspec-meta_2_11_7;
                  semigroupoids = hself.semigroupoids_6_0_0_1;
                  singleton-bool = hself.singleton-bool_0_1_7;
                  singletons-base = hself.singletons-base_3_3;
                  singletons-th = hself.singletons-th_3_3;
                  some = hself.some_1_0_6;
                  streaming-bytestring =
                    hsLib.doJailbreak hsuper.streaming-bytestring;
                  pipes-bytestring = hsLib.doJailbreak hsuper.pipes-bytestring;
                  tagged = hsuper.tagged_0_8_8;
                  th-abstraction = hself.th-abstraction_0_6_0_0;
                  th-desugar = hself.th-desugar_1_16;
                  turtle = hsLib.doJailbreak hsuper.turtle;
                  unlifted = hsLib.doJailbreak hsuper.unlifted;
                  primitive-unlifted =
                    hsLib.doJailbreak hsuper.primitive-unlifted;
                  half = hsLib.doJailbreak hsuper.half;
                  servant = hsLib.doJailbreak hself.servant_0_20_1;
                  servant-auth = hsLib.doJailbreak hsuper.servant-auth;
                  servant-auth-server = hsLib.doJailbreak
                    (hsLib.markUnbroken hsuper.servant-auth-server);
                  servant-server = hsLib.doJailbreak hself.servant-server_0_20;
                  servant-client = hsLib.doJailbreak hself.servant-client_0_20;
                  servant-client-core =
                    hsLib.doJailbreak hself.servant-client-core_0_20;
                  rebase = hself.rebase_1_20_1_1;
                  rerebase = hself.rerebase_1_20_1_1;
                  generic-lens = hsLib.doJailbreak hsuper.generic-lens;
                  websockets = hsLib.doJailbreak hsuper.websockets;
                  cborg =
                    hself.callCabal2nix "cborg" "${inputs.cborg}/cborg" { };
                  cborg-json = hself.callCabal2nix "cborg-json"
                    "${inputs.cborg}/cborg-json" { };
                  serialise =
                    hself.callCabal2nix "serialise" "${inputs.cborg}/serialise"
                    { };
                  binary-serialise-cbor =
                    hself.callCabal2nix "binary-serialise-cbor"
                    "${inputs.cborg}/binary-serialise-cbor" { };

                  # For compatibility with 'hedgehog' and GHC 9.8
                  tasty-hedgehog =
                    hsLib.doJailbreak hself.tasty-hedgehog_1_4_0_2;
                  hedgehog-classes = hsLib.doJailbreak hsuper.hedgehog-classes;

                  # For compatibility with 'tasty'
                  tasty = hsLib.doJailbreak hself.tasty_1_5;
                  tasty-hspec = hsLib.doJailbreak hself.tasty-hspec_1_2_0_4;
                  tasty-discover = hsLib.doJailbreak hsuper.tasty-discover;
                  tasty-quickcheck =
                    hsLib.doJailbreak hself.tasty-quickcheck_0_10_3;
                  integer-logarithms =
                    hsLib.doJailbreak hsuper.integer-logarithms;
                  tdigest = hsLib.doJailbreak hsuper.tdigest;
                  newtype-generics = hsLib.doJailbreak hsuper.newtype-generics;
                  bitvec = hsLib.doJailbreak hsuper.bitvec;
                  time-compat = hsLib.doJailbreak hsuper.time-compat;
                  indexed-traversable-instances =
                    hsLib.doJailbreak hsuper.indexed-traversable-instances;

                  # Required by 'hpack'
                  http-client-tls = hself.http-client-tls_0_3_6_3;

                  # Required by 'warp-tls'
                  tls = hself.tls_1_9_0;

                  # Required by 'warp-tls'. Tests disabled because of sandbox constraints.
                  warp = hsLib.dontCheck hself.warp_3_3_30;

                  # Required by 'hoogle'.
                  warp-tls = hself.warp-tls_3_4_3;

                  # For compatiblity with 'crypton-connection'
                  hoogle = hself.callCabal2nix "hoogle" inputs.hoogle { };
                  safe = hself.callCabal2nix "safe" inputs.safe { };
                  smtp-mail =
                    hself.callCabal2nix "smtp-mail" inputs.smtp-mail { };

                });
          };
        });
      systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
      perSystem = { config, pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.self.overlays.default ];
        };
      };
    };
}
