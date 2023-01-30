{ lib, buildDunePackage, luv, cmdliner, logs, fmt }:

buildDunePackage {
  pname = "redemon";
  version = "0.4.0";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/redemon/archive/0.4.0.tar.gz;
    sha256 = "0aflayj6fy484m76wa5ldwiaryabdbxskn1m9waql0wny1jwylsg";
  };

  propagatedBuildInputs = [ luv cmdliner logs fmt ];

  meta = {
    description = "nodemon replacement written in OCaml, with luv";
    license = lib.licenses.mit;
  };
}
