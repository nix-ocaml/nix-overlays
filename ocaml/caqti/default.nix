{ ocamlPackages }:

with ocamlPackages;

let
  buildCaqti = args: buildDunePackage (rec {
    version = "1.3.0";
    src = builtins.fetchurl {
      url = "https://github.com/paurkedal/ocaml-caqti/releases/download/v${version}/caqti-v${version}.tbz";
      sha256 = "0spi45ac4gwcmvjisx9w4k1n5ys5j2lmavfwfcr715w98av72pd1";
    };
  } // args);
in {
  caqti = buildCaqti {
    pname = "caqti";
    nativeBuildInputs = [ cppo ];
    propagatedBuildInputs = [
      ptime
      uri
      logs
    ];
  };

  caqti-lwt = buildCaqti {
    pname = "caqti-lwt";
    propagatedBuildInputs = [
      caqti
      logs
      lwt
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

