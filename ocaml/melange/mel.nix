{ buildDunePackage, cmdliner, melange, luv, cppo }:

buildDunePackage {
  pname = "mel";
  inherit (melange) src version;

  nativeBuildInputs = [ cppo ];
  propagatedBuildInputs = [ cmdliner melange luv ];
}
