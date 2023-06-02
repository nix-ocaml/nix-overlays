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
    inherit (reactjs-jsx-ppx) src;
    nativeBuildInputs = [ reason melange ];
    propagatedBuildInputs = [ reactjs-jsx-ppx melange ];
  };

  reactjs-jsx-ppx = buildDunePackage {
    pname = "reactjs-jsx-ppx";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "reasonml";
      repo = "reason-react";
      rev = "a35f96b153bfd653e095a3b2c235d38f37736844";
      hash = "sha256-zyuf4jXbk++lmVKcIftP9lHiNQKq0zlQK+RywZdwQnA=";
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
