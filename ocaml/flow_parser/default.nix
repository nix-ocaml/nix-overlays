{ buildDunePackage, base, ppx_deriving, ppx_gen_rec, sedlex, wtf8 }:

buildDunePackage {
  pname = "flow_parser";
  version = "0.186.0";
  src = builtins.fetchurl {
    url = https://github.com/facebook/flow/archive/refs/tags/v0.186.0.tar.gz;
    sha256 = "1hvck0pxcrx45jnp15xkxyw0dwmglw06vsm41lipfmgdfka0fxp1";
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
