{ ocamlPackages }:

with ocamlPackages;

let
  buildMirage = args: buildDunePackage (rec {
    version = "3.7.6";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/mirage/releases/download/v${version}/mirage-v${version}.tbz";
      sha256 = "060gl9n6ha131kf6668i1w5wcblz7p47wcrpq2zdi8v5imdlnrpq";
    };
  } // args);
in rec {
  mirage-runtime = buildMirage {
    pname = "mirage-runtime";
    propagatedBuildInputs = [
      ipaddr
      functoria-runtime
      fmt
      logs
      lwt4
    ];
  };
}

