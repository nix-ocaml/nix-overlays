{ lib, buildDunePackage, domainslib, fetchFromGitHub, lwt }:

buildDunePackage {
  pname = "lwt_domain";
  version = "0.2.0-dev";
  src = fetchFromGitHub {
    owner = "ocsigen";
    repo = "lwt_domain";
    rev = "0.3.0";
    hash = "sha256-NBskkMRb07Wt/G6B5mBG3Ct2JFJeNYNuTBfKf45w/qc=";
  };
  propagatedBuildInputs = [ domainslib lwt ];

  postPatch = ''
    substituteInPlace src/lwt_domain.ml --replace \
      "~num_additional_domains" "~num_domains:num_additional_domains"
  '';
  meta = {
    description = "Helpers for using Domainslib with Lwt";
    license = lib.licenses.mit;
  };
}
