{ oself, fetchFromGitHub }:

with oself;

{
  melange-atdgen-codec-runtime = buildDunePackage {
    pname = "melange-atdgen-codec-runtime";
    version = "n/a";
    src = builtins.fetchurl {
      url = "https://github.com/ahrefs/melange-atdgen-codec-runtime/releases/download/3.0.1/melange-atdgen-codec-runtime-3.0.1.tbz";
      sha256 = "1g5axhl8cqnhwky4nnsdpk4n3vxv95fr44k71kfi3zngvl9rrpya";
    };

    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange melange-json ];
  };

  melange-fetch = buildDunePackage {
    pname = "melange-fetch";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-fetch";
      rev = "a876cc42c2f1c3b0cbf370f1d15bbc788a62d785";
      hash = "sha256-has7M1qi5AjBLHQxH2wNg4JvLBV7jHXFQAAhs0OZoLw=";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange ];
  };

  melange-recharts = buildDunePackage {
    pname = "melange-recharts";
    version = "4.0.1";
    src = fetchFromGitHub {
      owner = "ahrefs";
      repo = "melange-recharts";
      rev = "2ff880588550897f8e2752f71d63aed9eae67d35";
      hash = "sha256-+YIC5JZGEAiTufZxbA3NTy65WqS77/YROLg0Hez9LUo=";
    };
    nativeBuildInputs = [ melange reason ];
    propagatedBuildInputs = [ melange reason-react ];
  };

  melange-testing-library = buildDunePackage {
    pname = "melange-testing-library";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-testing-library";
      rev = "45e0bc95270a66d9b6dd77c3ddf1ae72f36f7a19";
      hash = "sha256-xr8LTJwCX6IgkycKC1FBRn+YiA/HZDUmNJNsw8MM7N4=";
    };
    nativeBuildInputs = [ melange reason ];
    propagatedBuildInputs = [ melange reason-react ];
  };

  melange-json = buildDunePackage {
    inherit (melange-json-native) version src;
    pname = "melange-json";
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange ppxlib ];
  };

  melange-jest = buildDunePackage {
    pname = "melange-jest";
    version = "n/a";
    src = fetchFromGitHub {
      owner = "melange-community";
      repo = "melange-jest";
      rev = "b26885f193ed97ef9ab47447d21a1ddaa75d924a";
      hash = "sha256-PD22f/ySEwEtom5d9LNQoRQBQcCbyFIClj1wLnqk2oA=";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange reason-react ];
  };

  melange-numeral = buildDunePackage {
    pname = "melange-numeral";
    version = "0.0.1";
    src = builtins.fetchurl {
      url = "https://github.com/ahrefs/melange-numeral/releases/download/0.0.1/melange-numeral-0.0.1.tbz";
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
      rev = "0040e288bc47706e530ed7100d6e7bd80199c6c9";
      hash = "sha256-S2q+8ri6jDDwOkY3IUmFMZzx1tNZWl34XdYtmI5W6eQ=";
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
      rev = "18ed167f52b8c10ebefaf65534e6075614fa77b1";
      hash = "sha256-bA77GH80eSz0XsrEs+sgRvI9jtrSc14V6NjTsXOPoMc=";
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
      rev = "2452ff8b970cdbc8d31ae9549472a07a85a7093e";
      hash = "sha256-N8IjA0kQiY06W8ZuEPof7tZ6re9TlChrAQ1i5AqR4BY=";
    };
    propagatedBuildInputs = [ ppxlib ];
  };
}
