{ lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.2.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/ocaml-oidc/archive/e0cab24c70651b69c0b9533ca4604f7b0edcc539.tar.gz;
    sha256 = "sha256:0pgc119imh1imwfn7nskw52irgi4n2hp07q96qkr04q7ykd712mg";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
