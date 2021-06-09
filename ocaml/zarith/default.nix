{ stdenv, lib, pkgs, fetchFromGitHub, ocamlPackages, tezos ? false }:

with ocamlPackages;

if tezos then
  stdenv.mkDerivation
  rec {
    pname = "ocaml${ocaml.version}-zarith";
    version = "1.11";
    src = builtins.fetchurl {
      url = "https://github.com/ocaml/Zarith/archive/refs/tags/release-1.11.tar.gz";
      sha256 = "111n33flg4aq5xp5jfksqm4yyz6mzxx9ps9a4yl0dz8h189az5pr";
    };

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = [ ocaml findlib pkgs.perl ];
    propagatedBuildInputs = with pkgs; [ gmp ];

    patchPhase = "patchShebangs ./z_pp.pl";
    dontAddPrefix = true;
    configureFlags = [ "-installdir ${placeholder "out"}/lib/ocaml/${ocaml.version}/site-lib" ];

    preInstall = "mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/stublibs";

    meta = with lib; {
      description = "Fast, arbitrary precision OCaml integers";
      homepage = "http://forge.ocamlcore.org/projects/zarith";
      license = licenses.lgpl2;
      inherit (ocaml.meta) platforms;
    };
  }
else
  stdenv.mkDerivation
  rec {
    pname = "ocaml${ocaml.version}-zarith";
    version = "1.12";
    src = fetchFromGitHub {
      owner = "ocaml";
      repo = "Zarith";
      rev = "release-${version}";
      sha256 = "1jslm1rv1j0ya818yh23wf3bb6hz7qqj9pn5fwl45y9mqyqa01s9";
    };

    nativeBuildInputs = with pkgs; [ pkg-config ];
    buildInputs = [ ocaml findlib ];
    propagatedBuildInputs = with pkgs; [ gmp ];

    dontAddPrefix = true;
    configureFlags = [ "-installdir ${placeholder "out"}/lib/ocaml/${ocaml.version}/site-lib" ];

    preInstall = "mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/stublibs";

    meta = with lib; {
      description = "Fast, arbitrary precision OCaml integers";
      homepage = "http://forge.ocamlcore.org/projects/zarith";
      license = licenses.lgpl2;
      inherit (ocaml.meta) platforms;
    };
  }
  
