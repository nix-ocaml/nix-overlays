{ lib
, buildDunePackage
, fetchFromGitHub
, uri
, ocaml
}:

buildDunePackage {
  pname = "pure-html";
  version = "3.10.0";

  src =
    if lib.versionOlder "5.3" ocaml.version then
      fetchFromGitHub {
        owner = "yawaramin";
        repo = "dream-html";
        rev = "v3.11.2";
        hash = "sha256-/I233A86T+QEb2qbSHucgzRzYEjS08eKezSXOwz2ml0=";
      }
    else
      fetchFromGitHub {
        owner = "yawaramin";
        repo = "dream-html";
        rev = "v3.11.1";
        hash = "sha256-L/q3nxUONPdZtzmfCfP8nnNCwQNSpeYI0hqowioGYNg=";
      };

  propagatedBuildInputs = [ uri ];

  meta = {
    description =
      "Write HTML directly in your OCaml source files with editor support.";
    license = lib.licenses.gpl3;
  };
}
