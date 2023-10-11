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
    src = builtins.fetchurl {
      url = https://github.com/melange-community/melange-json/releases/download/1.0.0/melange-json-1.0.0.tbz;
      sha256 = "1adahq3ywjjvy9a68qmhlrg8hc7fk30vvfjg0hy0pwpihg7511yz";
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
      rev = "1fdc7b1b38c7aea6d412b28e7902f8cb338f565a";
      hash = "sha256-lpYujcmNNrJKCDkrZwdGQBh6wWXLc3CKh/VbL2eYFHA=";
    };
    propagatedBuildInputs = [ ppxlib ];
  };
}
