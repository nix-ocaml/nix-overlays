{ lib, buildDunePackage, jose, uri, yojson, logs }:


buildDunePackage {
  pname = "oidc";
  version = "0.1.1";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/ocaml-oidc/archive/ca3c178650d2472152456730aa58f2ff42ee5481.tar.gz;
    sha256 = "008sg5n81bgdgqz1bx4w5i1fd03nz7s2v3d6scda52z5dfx1a8ks";
  };

  propagatedBuildInputs = [ jose uri yojson logs ];

  meta = {
    description = "Base functions and types to work with OpenID Connect.";
    license = lib.licenses.bsd3;
  };
}
