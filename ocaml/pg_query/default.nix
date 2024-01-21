{ fetchFromGitHub
, buildDunePackage
, alcotest
, cmdliner
, ppx_deriving
, ctypes
, ctypes-foreign
}:

buildDunePackage {
  pname = "pg_query";
  version = "0.9.7";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "pg_query-ocaml";
    rev = "703b4dbfdf4aaee284ca53b8a92682210b0ed0a7";
    hash = "sha256-ICOh2N6ei8d7Ar0c1YOYV/NhhOzq2uLuIKu5dzMP9tM=";
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
