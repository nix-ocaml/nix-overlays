{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "morph";
  version = "0.6.2-dev";
  src = builtins.fetchurl {
    url = https://github.com/reason-native-web/morph/archive/64049af8d77a3fb6830e64bbf818931c5f9fef9c.tar.gz;
    sha256 = "10v5s3as6vsvm8vdz5bjywqiar6wzb83c63zyddbb69c3hgyqyqa";
  };

  propagatedBuildInputs = [
    reason
    fmt
    hmap
    logs
    lwt
    piaf
    session
    cookie
    digestif
    session-cookie
    session-cookie-lwt
    magic-mime
    uri
    routes
  ];

  meta = {
    description = "Webframework for Reason and OCaml.";
    license = lib.licenses.mit;
  };
}
