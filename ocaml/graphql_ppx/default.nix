{ fetchFromGitHub, buildDunePackage, cppo, yojson, ppxlib, reason }:

buildDunePackage {
  pname = "graphql_ppx";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "teamwalnut";
    repo = "graphql-ppx";
    rev = "1345e061a92394b651b5ac65a035fda4190292e4";
    sha256 = "sha256-WJXEnM4/T0McoP4/S57WpMd4tjW8V+vShPOL8oCJRko=";
  };

  nativeBuildInputs = [ cppo ];
  propagatedBuildInputs = [ yojson ppxlib reason ];

  postInstall = ''
    mkdir -p $out/lib-runtime
    cp -r ./package.json ./bsconfig.json ./rescript-runtime $out/lib-runtime
  '';
}
