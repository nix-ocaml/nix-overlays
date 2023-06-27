{ fetchFromGitHub, lib, buildDunePackage, lwt, eio }:

buildDunePackage {
  pname = "lwt_eio";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "ocaml-multicore";
    repo = "lwt_eio";
    rev = "220dfd5c57b3d8a620f908daa58dad993719e005";
    hash = "sha256-L8Th5edqERr0Yz9mlEn+sSQBY+HnyfFdrG0uU/Nm0MQ=";
  };

  propagatedBuildInputs = [ lwt eio ];
}
