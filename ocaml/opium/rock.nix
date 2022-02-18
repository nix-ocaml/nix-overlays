{ lib, buildDunePackage, lwt, bigstringaf, hmap, httpaf, sexplib0 }:

buildDunePackage {
  pname = "rock";
  version = "0.20.0-dev";
  src = builtins.fetchurl {
    url = https://github.com/ulrikstrid/opium/archive/830f02fb5462619314153cbe7cedf25e49468648.tar.gz;
    sha256 = "1d8s87ifdq8xnp27dahhy61xflgk4m1pz24qlw81dl2f6r443pcs";
  };

  propagatedBuildInputs = [ lwt bigstringaf hmap httpaf sexplib0 ];

  meta = {
    description = "Minimalist framework to build extensible HTTP servers and clients";
    license = lib.licenses.mit;
  };
}
