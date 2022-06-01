{ buildDunePackage, ppx_deriving, ppx_gen_rec, sedlex, wtf8 }:

buildDunePackage {
  pname = "flow_parser";
  version = "0.171.0";
  src = builtins.fetchurl {
    url = https://github.com/facebook/flow/archive/refs/tags/v0.171.0.tar.gz;
    sha256 = "0i0g36iymx49f2aabncaia1wgd358vaiqk6mia7nv42f2m8b26f5";
  };

  patches = [ ./flow.patch ];
  propagatedBuildInputs = [
    ppx_deriving
    ppx_gen_rec
    sedlex
    wtf8
  ];
}
