{
  description = "Overrides to upstream nixpkgs";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/0f36c44e01a6129be94e3ade315a5883f0228a6e";
    flake-parts.url = "github:hercules-ci/flake-parts";

    attoparsec-time = {
      url =
        "github:nikita-volkov/attoparsec-time/7c97d3667249a76946d8792b269935245e8301da";
      flake = false;
    };

    hourglass = {
      url =
        "github:k0001/hs-hourglass/cfc2a4b01f9993b1b51432f0a95fa6730d9a558a";
      flake = false;
    };

    stripeapi = {
      url =
        "github:Haskell-OpenAPI-Code-Generator/Stripe-Haskell-Library/b98f455f710c42bf8821a8c3d4e2c2aed7ff7a69";
      flake = false;
    };

    dani-servant-lucid2 = {
      url =
        "github:danidiaz/dani-servant-lucid2/3fefaa24f7a38bcd385a0489167dc0d96e56db2e";
      flake = false;
    };

    scotty = {
      url = "github:scotty-web/scotty/66d60f7a6828c7e9f8c7d2dc49e9597e7278b982";
      flake = false;
    };

    singletons_3_2 = {
      url =
        "github:goldfirere/singletons/f8a0708bf15289cc92a04c9902c3c2dc620a0b5e";
      flake = false;
    };

    esqueleto = {
      url =
        "github:bitemyapp/esqueleto/30a5e80736391e2aa45094f681d4bd329aa16707";
      flake = false;
    };

    headed-megaparsec = {
      url =
        "github:nikita-volkov/headed-megaparsec/3f4ef3d9ac30a1112cdc6cedd635bb01a9bb94a4";
      flake = false;
    };

    postgresql-syntax = {
      url =
        "github:nikita-volkov/postgresql-syntax/7cae094d542df6b2b370c6f98e08dc33fcb7004d";
      flake = false;
    };

    haskell-src-meta = {
      url =
        "github:haskell-party/haskell-src-meta/0b924b8bc4e0cf1aa254cd424d4107aa6d1bf4d7";
      flake = false;
    };

    hasql = {
      url =
        "github:nikita-volkov/hasql/2334d8d686ee037721be89ed54506407e15ecde7";
      flake = false;
    };

    hasql-interpolate = {
      url =
        "github:awkward-squad/hasql-interpolate/e0f6ad326e320dbfd4eaf3339969a08e2e7555d5";
      flake = false;
    };

    hasql-th = {
      url =
        "github:nikita-volkov/hasql-th/2dbba60bc67645de4d04c8e7f5403e83bb742abf";
      flake = false;
    };

    hasql-transaction = {
      url =
        "github:nikita-volkov/hasql-transaction/57a6ff13fbf83172b07ba72771c73a91faf81ab4";
      flake = false;
    };

    hasql-pool = {
      url =
        "github:nikita-volkov/hasql-pool/e7400b9983f153b792974ba5818a672743cdadab";
      flake = false;
    };

    smtp-mail = {
      url =
        "github:MasterWordServices/smtp-mail/4c724c80814ab1da7c37256a6c10e04c88b9af95";
      flake = false;
    };

    safe = {
      url = "github:ndmitchell/safe/748a635ed38582385a91c86a8847701f5ced63fd";
      flake = false;
    };

    odd-jobs = {
      url =
        "github:saurabhnanda/odd-jobs/411d5d0aaeeb96d4b72d0a434b9d2b53c88c2eae";
      flake = false;
    };

    hoogle = {
      url = "github:ndmitchell/hoogle/ee364a4bbe6f4936162edb99d90e332f9f6bb9e9";
      flake = false;
    };

    cborg = {
      url = "github:well-typed/cborg/64e2201485df2e6f62dfa5b26c96b289609f6153";
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
                  scotty = hself.callCabal2nix "scotty" inputs.scotty { };
                  headed-megaparsec = hself.callCabal2nix "headed-megaparsec"
                    inputs.headed-megaparsec { };
                  postgresql-syntax = hself.callCabal2nix "postgresql-syntax"
                    inputs.postgresql-syntax { };
                  haskell-src-meta = hself.callCabal2nix "haskell-src-meta"
                    "${inputs.haskell-src-meta}/haskell-src-meta" { };
                  hasql = hsLib.dontCheck
                    (hself.callCabal2nix "hasql" inputs.hasql { });
                  hasql-transaction = hsLib.dontCheck
                    (hself.callCabal2nix "hasql-transaction"
                      inputs.hasql-transaction { });
                  hasql-pool = hsLib.dontCheck
                    (hself.callCabal2nix "hasql-pool" inputs.hasql-pool { });
                  hasql-th = hself.callCabal2nix "hasql-th" inputs.hasql-th { };
                  hasql-interpolate = hsLib.dontCheck
                    (hself.callCabal2nix "hasql-interpolate"
                      inputs.hasql-interpolate { });
                  hasql-listen-notify =
                    hsLib.doJailbreak hsuper.hasql-listen-notify;

                  lucid-aria =
                    hsLib.markUnbroken (hsLib.doJailbreak hsuper.lucid-aria);
                  lucid-hyperscript = hsLib.markUnbroken
                    (hsLib.doJailbreak hsuper.lucid-hyperscript);
                  lucid2-htmx =
                    hsLib.markUnbroken (hsLib.doJailbreak hsuper.lucid2-htmx);

                  megaparsec = hself.megaparsec_9_6_1;
                  postgresql-simple =
                    hsLib.doJailbreak hself.postgresql-simple_0_7_0_0;
                  cookie-tray = hsLib.doJailbreak hsuper.cookie-tray;
                  postgresql-libpq =
                    hsLib.doJailbreak hself.postgresql-libpq_0_10_0_0;
                  postgresql-binary =
                    hsLib.doJailbreak hsuper.postgresql-binary;
                  isomorphism-class =
                    hsLib.doJailbreak hsuper.isomorphism-class;
                  text-builder = hsLib.doJailbreak hself.text-builder_0_6_7_2;
                  text-builder-dev =
                    hsLib.doJailbreak hself.text-builder-dev_0_3_4_2;

                  # broken
                  odd-jobs = hsLib.dontCheck
                    (hself.callCabal2nix "odd-jobs" inputs.odd-jobs { });
                  streaming-conduit = hsLib.doJailbreak
                    (hsLib.markUnbroken hsuper.streaming-conduit);
                  cassava-conduit = hsLib.doJailbreak
                    (hsLib.markUnbroken hsuper.cassava-conduit);
                  hspec-api = hsLib.markUnbroken hsuper.hspec-api;
                  mmzk-typeid =
                    hsLib.doJailbreak (hsLib.markUnbroken hsuper.mmzk-typeid);

                  # Tests don't compile
                  lifted-base = hsLib.dontCheck hsuper.lifted-base;

                  # Tests don't compile, compatibility with GHC 9.8
                  bsb-http-chunked =
                    hsLib.doJailbreak (hsLib.dontCheck hsuper.bsb-http-chunked);

                  # For compatibility with 'th-abstraction'
                  bifunctors = hself.bifunctors_5_6_1;
                  aeson = hself.aeson_2_2_1_0;
                  free = hself.free_5_2;

                  generics-sop = hself.generics-sop_0_5_1_4;

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
                  utf8-light = hsLib.doJailbreak hsuper.utf8-light;
                  streaming-bytestring =
                    hsLib.doJailbreak hsuper.streaming-bytestring;
                  esqueleto = hsLib.dontCheck
                    (hself.callCabal2nix "esqueleto" inputs.esqueleto { });
                  pipes-bytestring = hsLib.doJailbreak hsuper.pipes-bytestring;
                  tagged = hsuper.tagged_0_8_8;
                  th-abstraction = hself.th-abstraction_0_6_0_0;
                  th-desugar = hself.th-desugar_1_16;
                  turtle = hsLib.doJailbreak hsuper.turtle;
                  unlifted = hsLib.doJailbreak hsuper.unlifted;
                  primitive-unlifted =
                    hsLib.doJailbreak hsuper.primitive-unlifted;
                  half = hsLib.doJailbreak hsuper.half;
                  binary-parser = hsLib.doJailbreak hsuper.binary-parser;
                  bytestring-tree-builder =
                    hsLib.doJailbreak hsuper.bytestring-tree-builder;
                  servant = hsLib.doJailbreak hself.servant_0_20_1;
                  servant-auth = hsLib.doJailbreak hsuper.servant-auth;
                  servant-auth-server = hsLib.doJailbreak
                    (hsLib.markUnbroken hsuper.servant-auth-server);
                  servant-multipart =
                    hsLib.doJailbreak hsuper.servant-multipart;
                  servant-multipart-api =
                    hsLib.doJailbreak hsuper.servant-multipart-api;
                  servant-docs = hsLib.doJailbreak hself.servant-docs_0_13;
                  servant-foreign =
                    hsLib.doJailbreak hself.servant-foreign_0_16;
                  servant-server = hsLib.doJailbreak hself.servant-server_0_20;
                  servant-client = hsLib.doJailbreak hself.servant-client_0_20;
                  servant-client-core =
                    hsLib.doJailbreak hself.servant-client-core_0_20;
                  servant-static-th = hsLib.dontCheck
                    (hsLib.markUnbroken hsuper.servant-static-th);
                  servant-htmx =
                    hsLib.doJailbreak (hsLib.markUnbroken hsuper.servant-htmx);
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
                  alex = hself.alex_3_4_0_1;

                  criterion = hsLib.doJailbreak hsuper.criterion;

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
                  attoparsec-time =
                    hself.callCabal2nix "attoparsec-time" inputs.attoparsec-time
                    { };

                  # Required by 'hpack'
                  http-client-tls = hself.http-client-tls_0_3_6_3;

                  # Required by 'warp-tls'
                  tls = hself.tls_1_9_0;

                  # Required by 'warp-tls'. Tests disabled because of sandbox constraints.
                  warp = hsLib.dontCheck hself.warp_3_3_30;

                  # Required by 'hoogle'.
                  warp-tls = hself.warp-tls_3_4_3;

                  secp256k1-haskell = hself.secp256k1-haskell_1_1_0;

                  # For compatiblity with 'crypton-connection'
                  hoogle = hself.callCabal2nix "hoogle" inputs.hoogle { };
                  safe = hself.callCabal2nix "safe" inputs.safe { };
                  smtp-mail =
                    hself.callCabal2nix "smtp-mail" inputs.smtp-mail { };

                  stripeapi =
                    hself.callCabal2nix "stripeapi" inputs.stripeapi { };

                  dani-servant-lucid2 = hsLib.doJailbreak
                    (hself.callCabal2nix "dani-servant-lucid2"
                      inputs.dani-servant-lucid2 { });
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
