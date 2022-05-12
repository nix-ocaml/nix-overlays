{ lib, buildDunePackage, domainslib, lwt }:

buildDunePackage {
  pname = "lwt_domain";
  version = "0.2.0-dev";
  inherit (lwt) src;
  propagatedBuildInputs = [ domainslib lwt ];

  meta = {
    description = "Helpers for using Domainslib with Lwt";
    license = lib.licenses.mit;
  };
}
