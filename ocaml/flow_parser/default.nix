{ fetchFromGitHub, buildDunePackage, base, ppx_deriving, ppx_gen_rec, sedlex, wtf8 }:

buildDunePackage {
  pname = "flow_parser";
  version = "0.186.0";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "flow";
    rev = "v0.206.0";
    hash = "sha256-pDh43pOf/PhyxGcYRnQsuq7FBJz2Wru77QBTEYSobno=";
  };

  propagatedBuildInputs = [
    base
    ppx_deriving
    ppx_gen_rec
    sedlex
    wtf8
  ];
}
