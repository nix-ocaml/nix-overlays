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
      rev = "edae6cdcd1d27d4fe5cdcb6cb4b944ebf8ff9d8b";
      hash = "sha256-4p9dvztRREqw5XUDNIkiAsLBCo2zAwgUZCCSBKEry/w=";
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
      rev = "89f0b81f987925dced87118084a78c2c2629cf0a";
      hash = "sha256-iryo3OrPn4cK7bcz8oImbN7gMZyt7PyKKcZhS4P7uvM=";
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
