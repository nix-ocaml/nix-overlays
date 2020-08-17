{ stdenv, ocamlPackages, lib }:

with ocamlPackages;

let src = builtins.fetchurl {
  url = https://github.com/anmonteiro/piaf/archive/eba8d7a007c276d8d34a88b1752e8e6c5eec1c9a.tar.gz;
  sha256 = "17xagjbm3vxbsjkbpl3xzn40kxnb8mgmzv63sl3a8xpqixrlmz79";
};

in

  {
    piaf = ocamlPackages.buildDunePackage {
      pname = "piaf";
      version = "0.0.1-dev";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        bigstringaf
        findlib
        httpaf
        httpaf-lwt-unix
        h2
        h2-lwt-unix
        logs
        lwt_ssl
        magic-mime
        ssl
        uri
      ];

      meta = {
        description = "Client library for HTTP/1.X / HTTP/2 written entirely in OCaml.";
        license = stdenv.lib.licenses.bsd3;
      };
    };

    carl = stdenv.mkDerivation {
      name = "carl";
      version = "0.0.1-dev";
      inherit src;

      nativeBuildInputs = [dune_2 ocaml findlib];

      buildPhase = ''
        dune build bin/carl.exe --display=short --profile=release
      '';
      installPhase = ''
        mkdir -p $out/bin
        mv _build/default/bin/carl.exe $out/bin/carl
      '';

      buildInputs = [
        piaf
        cmdliner
        fmt
        camlzip
        ezgzip
      ];

      meta = {
        description = "Mini-clone of curl based on Piaf";
        license = stdenv.lib.licenses.bsd3;
      };
    };
  }

