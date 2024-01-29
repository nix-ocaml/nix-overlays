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
      rev = "0039ac6c88a87c71c8bb54f38c31d67c032d2c8f";
      hash = "sha256-+TchVofnTdPWqFq5FtoEjLO0+9wyTFobXBYvCkryA8c=";
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
      rev = "0a0f4d203be04d4412c558114d2332d4814a9bbb";
      hash = "sha256-SHaBn1y3TL5ONf6KoYEp9/4hG59GlJWB4A8lYO6BpMc=";
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
      rev = "e9d57c5212734858004cf6b8d4a4f677ea34aed4";
      hash = "sha256-5P4I+dAGw5ST2y/yu+mt0JQnfdhiNBb3PPAhj2ZESio=";
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
      rev = "cc76de77b5a8a81adb2694924ea1fe80f50e70d3";
      hash = "sha256-+bbmO9ZILH/aBZwl2BIoeFltv1cgw7ce3TW1wFHs6HA=";
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
