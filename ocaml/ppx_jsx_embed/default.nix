{ buildDunePackage, reason, ppxlib }:

buildDunePackage {
  pname = "ppx_jsx_embed";
  version = "0.0.0";
  src = builtins.fetchurl {
    url = https://github.com/melange-re/ppx_jsx_embed/archive/888ffc77.tar.gz;
    sha256 = "122r9y301a32nm33j3qzh6lzglapsc1nkw4a2cwym8i35d2s8v09";
  };
  doCheck = true;
  useDune2 = true;
  propagatedBuildInputs = [ reason ppxlib ];
}
