{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "reason";
  version = "3.6.0";

  src = builtins.fetchurl {
    url = https://github.com/facebook/reason/archive/773dbcd0982ff7b775a567f3c7b754ad15c165b1.tar.gz;
    sha256 = "1bis8vnl9g3vfmws9p698f936spd752qni7y2552w608y1vppnpf";
  };

  propagatedBuildInputs = [ menhir fix merlin-extend ocaml-migrate-parsetree ];

  buildInputs = [ cppo menhir ];

  patches = [
    ./patches/0001-rename-labels.patch
  ];
}
