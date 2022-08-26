{ buildDunePackage }:

buildDunePackage {
  pname = "timedesc-tzlocal";
  version = "0.9.0";
  src = builtins.fetchurl {
    url = https://github.com/daypack-dev/timere/archive/refs/tags/timedesc-0.9.0.tar.gz;
    sha256 = "19wj1h9my4i8mhvqfdgaflb0vl5v4larq62ljaf0a33xriqppmbj";
  };
}
