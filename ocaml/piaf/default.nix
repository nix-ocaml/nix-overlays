{ stdenv, ocamlPackages, lib, fetchFromGitHub }:

with ocamlPackages;

let src = fetchFromGitHub {
  owner = "anmonteiro";
  repo = "piaf";
  rev = "03bfe63806a7affb09f57a9ac5844fddf67446b6";
  sha256 = "13811z9v0c4s48k299qsb92mdihzinrm86zny99hxs4819hqspsn";
  fetchSubmodules = true;
};

in
  {
    piaf = ocamlPackages.buildDunePackage {
      pname = "piaf";
      version = "0.0.1-dev";
      inherit src;

      doCheck = true;
      checkInputs = [ alcotest alcotest-lwt ];

      propagatedBuildInputs = [
        logs
        lwt_ssl
        magic-mime
        ssl
        uri

        # (vendored) httpaf dependencies
        angstrom
        faraday
        gluten-lwt-unix
        psq
        pecu
        mrmime
      ];

      meta = {
        description = "An HTTP library with HTTP/2 support written entirely in OCaml";
        license = lib.licenses.bsd3;
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
        description = "`curl` clone implemented using Piaf.";
        license = lib.licenses.bsd3;
      };
    };
  }

