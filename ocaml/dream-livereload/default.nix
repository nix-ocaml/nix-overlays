{ buildDunePackage, dream, lambdasoup, lwt_ppx }:

buildDunePackage rec {
  pname = "dream-livereload";
  version = "0.2.0";
  src = builtins.fetchurl {
    url = https://github.com/tmattio/dream-livereload/releases/download/0.2.0/dream-livereload-0.2.0.tbz;
    sha256 = "1ppq4j823p57w7bmzclmlb035i1mhjwz86alwjr44bjv493h6rgr";
  };

  propagatedBuildInputs = [ dream lambdasoup lwt_ppx ];
}
