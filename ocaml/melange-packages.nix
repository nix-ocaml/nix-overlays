{ oself, fetchFromGitHub }:

with oself;

{
  reason-react = buildDunePackage {
    pname = "reason-react";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "reasonml";
      repo = "reason-react";
      rev = "e15e7288ee82bc41c25732ae87ff137db97fd8a3";
      hash = "sha256-uSRe3WOKFnlYO9K/iVL/9YcuC2tptj2SxRAlJSwKeKs=";
    };
    nativeBuildInputs = [ reason melange ];
    propagatedBuildInputs = [ reactjs-jsx-ppx melange ];
  };
}
