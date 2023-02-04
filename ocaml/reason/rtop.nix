{ buildDunePackage, cppo, reason, utop }:

buildDunePackage {
  inherit (reason) src version;
  pname = "rtop";
  nativeBuildInputs = [ cppo ];
  propagatedBuildInputs = [ utop reason ];

  meta.mainProgram = "rtop";
}
