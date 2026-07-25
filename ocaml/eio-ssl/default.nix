{
  fetchFromGitHub,
  buildDunePackage,
  ssl,
  eio,
}:

buildDunePackage {
  pname = "eio-ssl";
  version = "n/a";
  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "eio-ssl";
    rev = "0b8560cd6e18ca248af10fb23fe31a8e0068fff6";
    hash = "sha256-XhayIlGwGJm093W6DtILoEFfdhXomR44+mvz5Q9Yr1k=";
  };
  propagatedBuildInputs = [
    ssl
    eio
  ];
}
