{ oself, fetchFromGitHub }:

with oself;

{
  melange-fetch = buildDunePackage {
    pname = "melange-fetch";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-fetch";
      rev = "d2183ec245cbf5c7a8f99f8c41d2de0758c8cda7";
      hash = "sha256-HP+DfQSeOYCzKVdsnPLpDP/qz8bU9YNaJD2TPPfV7Hs=";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange ];
  };

  melange-relay = buildDunePackage {
    pname = "melange-relay";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "melange-relay";
      rev = "4860812ef8dbee12e7b6a05d0a52c18c1ef934d8";
      hash = "sha256-sH4X7KEME4Ie2ROo24cx3w4XRgJqvfIOmvGLOCSXli0=";
      sparseCheckout = [ "packages/rescript-relay" ];
    };
    nativeBuildInputs = [ melange reason ];
    propagatedBuildInputs = [
      reason-react
      reason-react-ppx
      graphql_parser
      melange
    ];
  };

  reason-react = buildDunePackage {
    pname = "reason-react";
    version = "n/a";
    inherit (reason-react-ppx) src;
    nativeBuildInputs = [ reason melange ];
    propagatedBuildInputs = [ reason-react-ppx melange ];
  };

  reason-react-ppx = buildDunePackage {
    pname = "reason-react-ppx";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "reasonml";
      repo = "reason-react";
      rev = "e80c1c9da2cabc4ad93b5b88f70648455bcbbfed";
      hash = "sha256-IdwDMPi5yEWEEnKhn0QTWffaIrh67LGDhTpi27IdgrE=";
    };
    propagatedBuildInputs = [ ppxlib ];
  };

  rescript-syntax = buildDunePackage {
    pname = "rescript-syntax";
    version = "n/a";
    inherit (melange) src patches;
    propagatedBuildInputs = [ ppxlib melange ];
  };
}
