{
  fetchFromGitHub,
  buildDunePackage,
  alcotest,
  cmdliner,
  ppx_deriving,
  ctypes,
  ctypes-foreign,
}:

buildDunePackage {
  pname = "pg_query";
  version = "0.9.7";
  NIX_CFLAGS_COMPILE = "-std=gnu17";
  src = builtins.fetchurl {
    url = "https://github.com/roddyyaga/pg_query-ocaml/releases/download/0.9.8/pg_query-0.9.8.tbz";
    sha256 = "11c31a10g44m487anwdqfnbxxjl9jlaj277845wmv1zprhcl5lmi";
  };

  propagatedBuildInputs = [
    ppx_deriving
    ctypes
    ctypes-foreign
    cmdliner
  ];
  doCheck = true;
  checkInputs = [ alcotest ];
}
