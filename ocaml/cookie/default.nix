{ fetchFromGitHub, lib, buildDunePackage, uri, ptime, astring }:

buildDunePackage {
  pname = "cookie";
  version = "0.1.8-dev";

  src = fetchFromGitHub {
    owner = "ulrikstrid";
    repo = "ocaml-cookie";
    rev = "95592ac37dc9209cf4f07544156aad7c3187dbab";
    sha256 = "sha256-souA7AOa59tu4Tdh7UEZm67YAz+1aR3asRZxk35WcHA=";
  };

  propagatedBuildInputs = [ uri ptime astring ];

  meta = {
    description = "Cookie parsing and serialization for OCaml";
    license = lib.licenses.bsd3;
  };
}
