{ lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.1.1";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/ocaml-oidc/archive/6af26046459f47864554c6b9cadac89f7fef2506.tar.gz;
    sha256 = "1hjsdlw5l4k7gpvrqimn5pbzqvhcsg2ja0q4jxpsx78xvsi140p8";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
