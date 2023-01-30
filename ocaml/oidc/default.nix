{ lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.2.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/ocaml-oidc/archive/4bb30333412593b899dfdc9e740465b06efb317e.tar.gz;
    sha256 = "1cav7scvb0i8j1nr0yzzxgbwy4r5kgn68a1nm4zdpvkk038ds4ji";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
