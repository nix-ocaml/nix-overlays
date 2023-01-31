{ fetchFromGitHub, buildDunePackage, base, ppx_deriving, ppx_gen_rec, sedlex, wtf8 }:

buildDunePackage {
  pname = "flow_parser";
  version = "0.186.0";
  src = fetchFromGitHub {
    owner = "facebook";
    repo = "flow";
    rev = "v0.186.0";
    sha256 = "sha256-Bip56IgE+XtNSwUC09ANe9ClSg6vTQO60spt1ijvs68=";
  };

  patches = [ ./flow.patch ];
  propagatedBuildInputs = [
    base
    ppx_deriving
    ppx_gen_rec
    sedlex
    wtf8
  ];
}
