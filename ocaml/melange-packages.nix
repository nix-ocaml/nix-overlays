{ oself, fetchFromGitHub }:

with oself;

{
  melange-fetch = buildDunePackage {
    pname = "melange-fetch";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "reasonml-community";
      repo = "bs-fetch";
      rev = "a6b69500fea09824f4b31b0b2ee3340935241881";
      hash = "sha256-tf0rcQ8cs0bMf29upvD+XcRXSHqdRvkROEHVM6mw1Ts=";
    };
    nativeBuildInputs = [ melange ];
  };

  melange-relay = buildDunePackage {
    pname = "melange-relay";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "rescript-relay";
      rev = "7d4de2abd6061ad2426a48dbabe0123c67e4b09a";
      hash = "sha256-9He/KIknyesRbo7PW/Rr6+unSJFVwCCGbr5Apupym3w=";
      sparseCheckout = [ "packages/rescript-relay" ];
    };
    nativeBuildInputs = [ melange reason ];
    propagatedBuildInputs = [ reason-react reactjs-jsx-ppx graphql_parser ];
  };

  reason-react = buildDunePackage {
    pname = "reason-react";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "reasonml";
      repo = "reason-react";
      rev = "b809c27db0e7db615a21623f075791093f53a3ce";
      hash = "sha256-AWo5JnjKjPR9AnJKdX8leain0z7LlMAC6BHYPn2igA0=";
    };
    nativeBuildInputs = [ reason melange ];
    propagatedBuildInputs = [ reactjs-jsx-ppx melange ];
  };
}
