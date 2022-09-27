{ lib, buildDunePackage, domainslib, lwt }:

buildDunePackage {
  pname = "lwt_domain";
  version = "0.2.0-dev";
  inherit (lwt) src;
  propagatedBuildInputs = [ domainslib lwt ];

  postPatch = ''
    substituteInPlace src/domain/lwt_domain.ml --replace \
      "~num_additional_domains" "~num_domains:num_additional_domains"
  '';
  meta = {
    description = "Helpers for using Domainslib with Lwt";
    license = lib.licenses.mit;
  };
}
