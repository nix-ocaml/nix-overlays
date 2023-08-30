{ fetchFromGitHub, buildDunePackage, ssl, eio }:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "eio-ssl";
    rev = "c5c9c3562baf771f7a00fa52b52dfe1f956b5489";
    hash = "sha256-67Mjh/GmnjLMfubcXHUVXeRe2pyhezT4IPX0E7DSXEg=";
  };
  propagatedBuildInputs = [ ssl eio ];
}
