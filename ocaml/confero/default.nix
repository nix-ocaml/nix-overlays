{
  buildDunePackage,
  fetchFromGitHub,
  unzip,
  angstrom,
  angstrom-unix,
  cmdliner,
  fmt,
  iso639,
  uucp,
  uunf,
  uutf,
}:

buildDunePackage {
  pname = "confero";
  version = "0.1.1";
  src = fetchFromGitHub {
    owner = "paurkedal";
    repo = "confero";
    rev = "252cf3e";
    sha256 = "sha256-YJyyT4uimLJQH0/bIMe/FCPk0ZYemgHYxV4uaQXVE6w=";
  };

  nativeBuildInputs = [ unzip ];
  postPatch = ''
    cp ${./allkeys.txt} ./lib/ducet/allkeys.txt
    cp ${./CollationTest.zip} ./test/CollationTest.zip
  '';

  doCheck = false;

  propagatedBuildInputs = [
    angstrom
    angstrom-unix
    cmdliner
    fmt
    iso639
    uucp
    uunf
    uutf
  ];
}
