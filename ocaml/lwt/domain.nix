{ lib, buildDunePackage, domainslib, fetchFromGitHub, lwt }:

buildDunePackage {
  pname = "lwt_domain";
  version = "0.2.0-dev";
  src = fetchFromGitHub {
    owner = "ocsigen";
    repo = "lwt_domain";
    rev = "28319c184a648c9e79f60b8ba4f57c271f7e9606";
    hash = "sha256-rjjJX19/SuKUdvlE8BfV0iGdzmFLF+F8L4HzG4ja2HI=";
  };
  propagatedBuildInputs = [ domainslib lwt ];

  meta = {
    description = "Helpers for using Domainslib with Lwt";
    license = lib.licenses.mit;
  };
}
