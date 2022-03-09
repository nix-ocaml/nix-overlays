{ buildDunePackage, cppo, yojson, ppxlib, reason }:

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.1.0";

  src = builtins.fetchurl {
    url = https://github.com/teamwalnut/graphql-ppx/archive/refs/tags/v1.2.3.tar.gz;
    sha256 = "0jwaf4rac2c9n4k01hf3krjklflhld0z0wynh32666yav10h4zdb";
  };

  useDune2 = true;
  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [ yojson ppxlib reason ];

  postInstall = ''
    mkdir $out/lib_bucklescript
    cp -r ./package.json ./bsconfig.json ./bucklescript $out/lib_bucklescript
  '';
}
