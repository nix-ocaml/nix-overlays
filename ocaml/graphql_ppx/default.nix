{ buildDunePackage, cppo, yojson, ppxlib, reason }:

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.2.3";

  src = builtins.fetchurl {
    url = https://github.com/teamwalnut/graphql-ppx/archive/1345e061a92394b651b5ac65a035fda4190292e4.tar.gz;
    sha256 = "0cwzj539v4v2zk1wfm0d2cysymh2wms083d2pvm4j7mjfh1dlpic";
  };

  nativeBuildInputs = [ cppo ];
  propagatedBuildInputs = [ yojson ppxlib reason ];

  postInstall = ''
    mkdir -p $out/lib-runtime
    cp -r ./package.json ./bsconfig.json ./rescript-runtime $out/lib-runtime
  '';
}
