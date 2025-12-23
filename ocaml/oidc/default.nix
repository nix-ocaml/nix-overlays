{
  fetchFromGitHub,
  lib,
  buildDunePackage,
  jose,
  uri,
  yojson,
  logs,
}:

buildDunePackage {
  pname = "oidc";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-oidc";
    rev = "v0.2.0";
    hash = "sha256-j88F76W5KZVYdZHI1Im24fbbOTect7/LlNfh/KY1mU0=";
  };

  propagatedBuildInputs = [
    jose
    uri
    yojson
    logs
  ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
