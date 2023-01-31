{ fetchFromGitHub, lib, buildDunePackage, lwt, eio }:

buildDunePackage {
  pname = "lwt_eio";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "ocaml-multicore";
    repo = "lwt_eio";
    rev = "557403cebb";
    sha256 = "sha256-1VXvqNLG42QN/3BlVOjvkD+JQYMqO5focQeuNj+zfIk=";
  };

  propagatedBuildInputs = [ lwt eio ];
}
