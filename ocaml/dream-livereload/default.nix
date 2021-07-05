{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "dream-livereload";
  version = "0.1.0";
  src = builtins.fetchurl {
    url = "https://github.com/tmattio/dream-livereload/archive/refs/tags/${version}.tar.gz";
    sha256 = "0id3yav4wgn5klx5gdh7mnb91ppa7z80f9279csvgy1qrzca65ja";
  };

  propagatedBuildInputs = [
    dream
    lambdasoup
    lwt_ppx
  ];
}
