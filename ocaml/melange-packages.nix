{ oself, fetchFromGitHub }:

with oself;

{
  melange-fetch = buildDunePackage {
    pname = "melange-fetch";
    version = "n/a";
    src = builtins.fetchurl {
      url = https://github.com/melange-community/melange-fetch/releases/download/0.1.0/melange-fetch-0.1.0.tbz;
      sha256 = "0y7z8jrwjgim2wgwg1ajjc1g365wgppgl3wza6b3955ahghjgyl8";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange ];
  };

  melange-testing-library = buildDunePackage {
    pname = "melange-testing-library";
    version = "n/a";
    src = builtins.fetchurl {
      url = https://github.com/melange-community/melange-testing-library/releases/download/0.1.0/melange-testing-library-0.1.0.tbz;
      sha256 = "1mhir158zwpfigb75plgzz93i8jfnfjibdii2vh19vr3gcly7k23";
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
      rev = "3bb100347eadf16c81c12c989e885a0dda23ea16";
      hash = "sha256-gi5Cgq+Ybu8NNXtIjFSfVJ3A7S5KBjUPPKLtkEVqhY8=";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange ];
  };

  melange-jest = buildDunePackage {
    pname = "melange-jest";
    version = "n/a";
    src = builtins.fetchurl {
      url = https://github.com/melange-community/melange-jest/releases/download/0.1.0/melange-jest-0.1.0.tbz;
      sha256 = "1nv926jxl4yp15iwqd127bvdpfhvh8l9rkffd7l6p701xxk72ln4";
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
    src = builtins.fetchurl {
      url = https://github.com/melange-community/melange-webapi/releases/download/0.20.0/melange-webapi-0.20.0.tbz;
      sha256 = "0hw165mmcl0a57g0qas0zbi429rskm1cpy5qlkcwnmn8aax8z8pf";
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
      rev = "3b9430c441b0d15fb435d80c2f5d5993200be182";
      hash = "sha256-z58p6Cz9HjAI55d1PVuVbW121qWaWMtDfYk7CKIg0VY=";
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
      rev = "1f084f4ecf380b2144809065e5935a41866eab3f";
      hash = "sha256-F+n+8j1tEs6C0U4P/kmnHQIUPdnBXjazt+Sz2Y+S238=";
    };
    propagatedBuildInputs = [ ppxlib ];
  };
}
