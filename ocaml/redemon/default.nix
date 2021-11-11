{ lib, buildDunePackage, luv, cmdliner, logs, fmt }:

buildDunePackage {
  pname = "redemon";
  version = "0.4.0";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/redemon/archive/0.4.0.tar.gz;
    sha256 = "0v12zm2j8qa0ypkiq9dnll617ylqkv1f2xpdyadz46iv31dzdk3s";
  };

  propagatedBuildInputs = [ luv cmdliner logs fmt ];

  meta = {
    description = "nodemon replacement written in OCaml, with luv";
    license = lib.licenses.mit;
  };
}
