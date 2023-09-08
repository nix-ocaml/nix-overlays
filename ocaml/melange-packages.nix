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
      rev = "567a2f7fac31d263c3315f8b4ed0183d6c6762b4";
      hash = "sha256-GEIwd1m+FNJdToFFUCEFlQ3wPHcRcH3L/LZ48UIbbWQ=";
      sparseCheckout = [ "packages/rescript-relay" ];
    };
    nativeBuildInputs = [ melange ];
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
      rev = "2e99c8ee87cefe241b698c191c74226da54cf9db";
      hash = "sha256-PZTlTgZHaF/ap0BLdWG/LFna5THFPcq8BrouPbn8eKA=";
    };
    propagatedBuildInputs = [ ppxlib ];
  };
}
