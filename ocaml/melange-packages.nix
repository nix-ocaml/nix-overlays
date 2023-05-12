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

  melange-relay = buildDunePackage {
    pname = "melange-relay";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "rescript-relay";
      rev = "669abf4ce74bbe22cbd811c97cc9e86de3dd1850";
      hash = "sha256-MOFjbzx9M/qNAvWAWA1MHhtI634PjQo/Qg4pgwTtBhU=";
      sparseCheckout = [ "packages/rescript-relay" ];
    };
    nativeBuildInputs = [ rescript-syntax melange reason ];
    propagatedBuildInputs = [ reason-react reactjs-jsx-ppx melange graphql_parser ];
  };
}
