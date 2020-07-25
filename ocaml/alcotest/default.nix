{ ocamlPackages }:

with ocamlPackages;

let
  buildAlcotest = args: buildDunePackage (rec {
    version = "1.2.1";

    useDune2 = true;

    src = builtins.fetchurl {
      url = "https://github.com/mirage/alcotest/releases/download/${version}/alcotest-mirage-${version}.tbz";
      sha256 = "0v6cwdsisaw0qh5pygygzflxr084kwhcj4vk7l08b5ixn2mkgh2c";
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

  alcotest-mirage = buildAlcotest {
    pname = "alcotest-mirage";
    propagatedBuildInputs = [ alcotest lwt logs mirage-clock duration ];
  };

}

