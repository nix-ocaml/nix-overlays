{ lib, ocamlPackages, ocamlVersion }:

with ocamlPackages;
let
  buildHttpaf = args: buildDunePackage ({
    version = "0.7.0-dev";
    src = builtins.fetchurl {
      url = https://github.com/anmonteiro/httpaf/archive/909297dd811fcd03bf8ce54affd7da21ad31c067.tar.gz;
      sha256 = "0h5jfnrxqfg9jk49l8zq6g551nnm0qh29mnza1cjm4jb7vbsj54n";
    };
  } // args);
in
{
  httpaf = buildHttpaf {
    pname = "httpaf";
    propagatedBuildInputs = [ angstrom faraday ];
  };

  httpaf-lwt = buildHttpaf {
    pname = "httpaf-lwt";
    propagatedBuildInputs = [ httpaf gluten-lwt lwt ];
  };

  httpaf-lwt-unix = buildHttpaf {
    pname = "httpaf-lwt-unix";
    propagatedBuildInputs = [
      httpaf
      httpaf-lwt
      gluten-lwt-unix
      faraday-lwt-unix
      lwt_ssl
    ];
  };
} // (if (lib.versionOlder "4.08" ocamlVersion) then {
  httpaf-async = buildHttpaf {
    pname = "httpaf-async";
    doCheck = false;
    propagatedBuildInputs = [
      httpaf
      async
      gluten-async
      faraday-async
      async_ssl
    ];
  };

  httpaf-mirage = buildHttpaf {
    pname = "httpaf-mirage";
    doCheck = false;
    propagatedBuildInputs = [
      conduit-mirage
      httpaf-lwt
      gluten-mirage
    ];
  };
} else { })
