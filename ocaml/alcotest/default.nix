{ ocamlPackages }:

with ocamlPackages;

let
  buildAlcotest = args: buildDunePackage (rec {
    version = "1.2.2";

    useDune2 = true;

    src = builtins.fetchurl {
      url = "https://github.com/mirage/alcotest/releases/download/${version}/alcotest-mirage-${version}.tbz";
      sha256 = "0705mmv9b4m6fv1ndq8zqpma5k66c2idh920xi2xi5wmzkwgvfxl";
    };
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

  alcotest-mirage = buildAlcotest {
    pname = "alcotest-mirage";
    propagatedBuildInputs = [ alcotest lwt logs mirage-clock duration ];
  };

}

