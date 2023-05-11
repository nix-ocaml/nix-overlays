{ oself, fetchFromGitHub }:

with oself;

{
  reason-react = buildDunePackage {
    pname = "reason-react";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "reasonml";
      repo = "reason-react";
      rev = "d7011fe34d80f576ac39e706823cc6e35d13fd5f";
      hash = "sha256-gx3VomuOu1ywMnJNmYVunyvEX+Z903vb0ZJHh7kWpFs=";
    };
    nativeBuildInputs = [ reason melange ];
    propagatedBuildInputs = [ reactjs-jsx-ppx melange ];
  };
}
