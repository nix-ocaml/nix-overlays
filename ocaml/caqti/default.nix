{ ocamlPackages }:

with ocamlPackages;

let
  buildCaqti = args: buildDunePackage (rec {
    version = "1.2.2";
    src = builtins.fetchurl {
      url = "https://github.com/paurkedal/ocaml-caqti/releases/download/v${version}/caqti-v${version}.tbz";
      sha256 = "1g33gjk23hk915spgl18rljygmad700lii1ky06654svl4a3wzh9";
    };
  } // args);
in rec {
  caqti = buildCaqti {
    pname = "caqti";
    nativeBuildInputs = [ cppo ];
    propagatedBuildInputs = [
      ptime
      ppx_deriving
      uri
      logs
    ];
  };

  caqti-lwt = buildCaqti {
    pname = "caqti-lwt";
    propagatedBuildInputs = [
      caqti
      logs
      lwt4
    ];
  };

  caqti-type-calendar = buildCaqti {
    pname = "caqti-type-calendar";
    propagatedBuildInputs = [
      caqti
      calendar
    ];
  };

  caqti-driver-postgresql = buildCaqti {
    pname = "caqti-driver-postgresql";
    propagatedBuildInputs = [
      caqti
      postgresql
    ];
  };

}

