{ buildDunePackage, timedesc-tzlocal }:

buildDunePackage {
  pname = "timedesc-tzdb";
  inherit (timedesc-tzlocal) src version;
}
