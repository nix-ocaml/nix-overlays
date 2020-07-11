{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "jose";
  version = "0.4.0";
  src = builtins.fetchurl {
    # WIP version, doesn't support AES256 fully
    url = https://github.com/ulrikstrid/reason-jose/archive/69ac466b37252b1f263468a02eebf599724a9b84.tar.gz;
    sha256 = "0vh95a59c08vfzdsfmzihm6niqclnp84yxy9iip6mc20vf77zgph";
  };

  propagatedBuildInputs = [
    base64
    mirage-crypto
    x509
    cstruct
    astring
    yojson
    zarith
    result
  ];
}
