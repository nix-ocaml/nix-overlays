{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "graphql_ppx";
  version = "1.0.0-beta.20";

  src = fetchFromGitHub {
    owner = "reasonml-community";
    repo = "graphql-ppx";
    rev = "v${version}";
    sha256 = "1qfm9dgd9ycc4asfv3grl0axr7ir9fxvncmd4jbx7mhii35igdfb";
  };

  useDune2 = true;
  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs = [
    yojson
    ocaml-migrate-parsetree
    ppx_tools_versioned
    reason
    menhir
  ];

  postInstall = ''
    mkdir $out/lib_bucklescript
    cp -r ./package.json ./bsconfig.json ./bucklescript $out/lib_bucklescript
  '';
}
