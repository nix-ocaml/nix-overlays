{ buildDunePackage, async, caqti-async, ppx_rapper }:

buildDunePackage {
  pname = "ppx_rapper_async";
  inherit (ppx_rapper) src version;

  propagatedBuildInputs = [ async caqti-async ppx_rapper ];
}
