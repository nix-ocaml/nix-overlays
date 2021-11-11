{ lib, buildDunePackage, mirage-crypto, mirage-crypto-rng, base64 }:

buildDunePackage {
  pname = "session";
  version = "0.5.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/inhabitedtype/ocaml-session/archive/6180413996e8c95bd78a9afa1431349a42c95588.tar.gz;
    sha256 = "11gs6jybbvyvdndpxi4q4z60ncvza1b4v67qk4fm4xrj7y2im4fs";
  };

  propagatedBuildInputs = [ mirage-crypto mirage-crypto-rng base64 ];

  meta = {
    description = "A session manager for your everyday needs";
    license = lib.licenses.bsd3;
  };
}
