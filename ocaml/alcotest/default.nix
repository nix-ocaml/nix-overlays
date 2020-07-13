{ ocamlPackages }:

with ocamlPackages;

let
  buildAlcotest = args: buildDunePackage (rec {
    version = "1.2.0";

    useDune2 = true;

    src = builtins.fetchurl {
      url = "https://github.com/mirage/alcotest/releases/download/${version}/alcotest-mirage-${version}.tbz";
      sha256 = "11xa9ncx7sxhby1apgl8qvinifwn40cqp5nxsq5k4qhk10v74ayq";
    };

    postInstall = ''
      rm $OCAMLFIND_DESTDIR/${args.pname}/dune-package
    '';
  } // args);
in
{
  alcotest = buildAlcotest {
    pname = "alcotest";
    propagatedBuildInputs = [ astring cmdliner fmt uuidm stdlib-shims uutf re ];
  };

  alcotest-lwt = buildAlcotest {
    pname = "alcotest-lwt";
    propagatedBuildInputs = [ alcotest lwt logs ];
  };

}

