{ oself, fetchFromGitHub }:

with oself;

{
  melange-fetch = buildDunePackage {
    pname = "melange-fetch";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-fetch";
      rev = "796f941b6b85eb7e6182ac6e4f40708bfde7a9a9";
      hash = "sha256-Ey6HNUoJL13iMpm2vchmrD5pEM2/G+HsrkPQrzRZwQ8=";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange ];
  };

  melange-testing-library = buildDunePackage {
    pname = "melange-testing-library";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-testing-library";
      rev = "5e2c75af13aa9a8ae56f7d94568d4661e2b5642d";
      hash = "sha256-475yUCAv1ZAoh5dh7bvEZe0DR3vGCvQyNH35n9Sj3sU=";
    };
    nativeBuildInputs = [ melange reason ];
    propagatedBuildInputs = [ melange reason-react ];
  };

  melange-json = buildDunePackage {
    pname = "melange-json";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-json";
      rev = "9f56e03b1a0beaa3625564af44b26c6381b3c293";
      hash = "sha256-P2ZF3S9R52jdVHfDH02hqdYM83n0ew8Mr5LZrujk7go=";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange ];
  };

  melange-jest = buildDunePackage {
    pname = "melange-jest";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-jest";
      rev = "acb6ef50beef3c486805d616b90aa7b56b51172d";
      hash = "sha256-0dAMCt0+niBpM2uLCDqo1DYyyAbFPQ4EedY6LG/lQac=";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange reason-react ];
  };

  melange-webapi = buildDunePackage {
    pname = "melange-webapi";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-webapi";
      rev = "e3b2486138fb7107cfd73d34092fd65cbd1262b0";
      hash = "sha256-n2p6sEw2cb2H1Dse7PwXrMbXgbqt80sIxnPH1/hwb+8=";
    };
    nativeBuildInputs = [ melange reason ];
    propagatedBuildInputs = [ melange melange-fetch ];
  };

  melange-relay = buildDunePackage {
    pname = "melange-relay";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "melange-relay";
      rev = "cf654d4dd9b694b968a20e23db29a273e059e945";
      hash = "sha256-Gy5Z/1WmhQy+xQvW0Ef2b9kmh4eLz2Cv+wUG+yAPp+0=";
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
      rev = "0ab8d33bd811e02f8d14e202a07ca82f4da6fb33";
      hash = "sha256-sbKhRKdzglGgKouoQoGJCLAffoYv8k0vNvPiE9M96yM=";
    };
    propagatedBuildInputs = [ ppxlib ];
  };
}
