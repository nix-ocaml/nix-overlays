{ buildDunePackage, cppo, yojson, ppxlib, reason }:

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.2.3";

  src = builtins.fetchurl {
    url = https://github.com/teamwalnut/graphql-ppx/archive/4a1fbfebf9.tar.gz;
    sha256 = "0d1kadwgdsdfma12f6rfssy8qqk8nkcx7650wvr53y8ck0yr3kqs";
  };

  nativeBuildInputs = [ cppo ];
  propagatedBuildInputs = [ yojson ppxlib reason ];

  postInstall = ''
    mkdir -p $out/lib-runtime
    cp -r ./package.json ./bsconfig.json ./rescript-runtime $out/lib-runtime
  '';
}
