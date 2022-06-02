{ buildDunePackage, cppo, reason, utop }:

buildDunePackage {
  inherit (reason) src version;
  pname = "rtop";
  buildInputs = [ cppo ];
  propagatedBuildInputs = [ utop reason ];

  meta.mainProgram = "rtop";
}
