{ oself, fetchFromGitHub }:

with oself;

{
  melange-fetch = buildDunePackage {
    pname = "melange-fetch";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-fetch";
      rev = "bb67c4de36ef00f90424561e630522ee2f57fe54";
      hash = "sha256-A0l4r++sTZ0NaIUdg7hlH1XfmznnLumlofvOCvUYwrc=";
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
      rev = "443fdffd33e9eee0cc1e4922c49d9bfc738044be";
      hash = "sha256-vLXq8cGQ5j5xfQF6ZjrPhKOFQ5WvCVcyNPDxYYpPb3k=";
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

  melange-numeral = buildDunePackage {
    pname = "melange-numeral";
    version = "0.0.1";
    src = builtins.fetchurl {
      url = https://github.com/ahrefs/melange-numeral/releases/download/0.0.1/melange-numeral-0.0.1.tbz;
      sha256 = "1a16j014ps835xqks7mgybqqq34rpvhnzbibrh1pypcqa7hhcdnd";
    };
    nativeBuildInputs = [ melange reason ];
    propagatedBuildInputs = [ melange ];
  };

  melange-webapi = buildDunePackage {
    pname = "melange-webapi";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-webapi";
      rev = "e06f7711ea51a25274daca249fc4fcf17357a85c";
      hash = "sha256-DX+wh27tKQ5tDT/+Ba1jkgXAGKf8YjLYiLeOr2XzSo4=";
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
      rev = "ac33eecf90b68a8696f27e15698013c032d99f6f";
      hash = "sha256-1/5unalmwbP7YvSU6bZvssT6TdBx7+0IzuYFXLssduA=";
    };
    propagatedBuildInputs = [ ppxlib ];
  };
}
