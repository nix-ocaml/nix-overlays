{ buildDunePackage, ppx_rapper, eio, caqti-eio }:

buildDunePackage {
  pname = "ppx_rapper_eio";
  inherit (ppx_rapper) src version;

  propagatedBuildInputs = [ ppx_rapper eio caqti-eio ];
}
