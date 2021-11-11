{ lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.1.1";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/ocaml-oidc/archive/v0.1.1.tar.gz;
    sha256 = "1k729n94zx5qjc701s41dn4bjyqxznzbrwck713rni4w3yzparys";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
