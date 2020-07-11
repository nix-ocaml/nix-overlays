{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "jose";
  version = "0.4.0";
  src = builtins.fetchurl {
    # WIP version, doesn't support AES256 fully
    url = "https://github.com/ulrikstrid/reason-jose/archive/cc3b292daea1069de334879765d0c914a706f21d.tar.gz";
    sha256 = "1hpykm0rxiy2q909v6jsdw352zkmmyflxis8m5kwpqzfa1w8kjz2";
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
