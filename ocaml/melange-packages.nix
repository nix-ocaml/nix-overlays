{ oself, fetchFromGitHub }:

with oself;

{
  melange-fetch = buildDunePackage {
    pname = "melange-fetch";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "reasonml-community";
      repo = "bs-fetch";
      rev = "7e3ee61562884c83d03c5e0fbf37bb4f7c4eaf68";
      hash = "sha256-egUYML8wd5IhZ9vF/pUSM+B72jYxZ4jllbCwUof2ilU=";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange ];
  };

  melange-relay = buildDunePackage {
    pname = "melange-relay";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "rescript-relay";
      rev = "022781d8e3a86983cbb4e00330e3982e9b0aa24d";
      hash = "sha256-6oAy72YI7e9JrYmbykzEXp3DKz9hgMxbKcd4xWFUvIU=";
      sparseCheckout = [ "packages/rescript-relay" ];
    };
    nativeBuildInputs = [ melange reason ];
    propagatedBuildInputs = [ reason-react reactjs-jsx-ppx graphql_parser melange-fetch ];
  };

  reason-react = buildDunePackage {
    pname = "reason-react";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "reasonml";
      repo = "reason-react";
      rev = "1c35274e7c1c3df96f0e71b59793b365850fcdb8";
      hash = "sha256-xKwc46QbdSuuuBKhtBKgERdYZS0Vu/R7arzl5nqF2DI=";
    };
    nativeBuildInputs = [ reason melange ];
    propagatedBuildInputs = [ reactjs-jsx-ppx melange ];
  };
}
