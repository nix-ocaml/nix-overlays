{ ocamlPackages }:

with ocamlPackages;

let
  buildJunit = args: buildDunePackage (rec {
    version = "2.0.2";

    src = builtins.fetchurl {
      url = "https://github.com/Khady/ocaml-junit/releases/download/${version}/junit-${version}.tbz";
      sha256 = "00bbx5j8vsy9fqbc04xa3lsalaxicirmbczr65bllfk1afv43agx";
    };
  } // args);

in rec {
  junit = buildJunit {
    pname = "junit";
    propagatedBuildInputs = [ ptime tyxml ];
  };

  junit_alcotest = buildJunit {
    pname = "junit_alcotest";
    propagatedBuildInputs = [ junit alcotest ];
  };
}

