{ oself, fetchFromGitHub }:

with oself;

{
  melange-atdgen-codec-runtime = buildDunePackage {
    pname = "melange-atdgen-codec-runtime";
    version = "n/a";
    src = builtins.fetchurl {
      url = https://github.com/ahrefs/melange-atdgen-codec-runtime/releases/download/3.0.0/melange-atdgen-codec-runtime-3.0.0.tbz;
      sha256 = "1fkw1ynqzmpf9h6jkqzcfv2i2cw4a16wmvbmc8hmgw0wymb99m2n";
    };

    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange melange-json ];
  };

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

  melange-recharts = buildDunePackage {
    pname = "melange-recharts";
    version = "4.0.1";
    src = fetchFromGitHub {
      owner = "ahrefs";
      repo = "melange-recharts";
      rev = "fda583ba97148e09d5c3961d8278c189ce261b81";
      hash = "sha256-ejuXTLhMiRzyC6yJLd5xPzGUoj1fDP2/TaELlFKJJVM=";
    };
    nativeBuildInputs = [ melange reason ];
    propagatedBuildInputs = [ melange reason-react ];
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
      url = https://github.com/melange-community/melange-json/releases/download/1.1.0/melange-json-1.1.0.tbz;
      sha256 = "12ih5drzrxjd70wfc0lz7q9pm6pm3j3wxnvwmqlvngvkkkh8dgnz";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [ melange ];
  };

  melange-jest = buildDunePackage {
    pname = "melange-jest";
    version = "n/a";
    src = builtins.fetchurl {
      url = https://github.com/melange-community/melange-jest/releases/download/0.1.1/melange-jest-0.1.1.tbz;
      sha256 = "1vnn19bz5sqnvrpl6wma50q8a75diyb9ddl19061halga3a410y6";
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
      url = https://github.com/melange-community/melange-webapi/releases/download/0.21.0/melange-webapi-0.21.0.tbz;
      sha256 = "1h8j3fy6d0shxv9wjhgmm85ac7f69waz9ay3khw8impiv6h5w00k";
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
      rev = "fd3bfd537744bf75139c4736987e95183af878e5";
      hash = "sha256-0r62kRFXwx1JvuOocZL8o3IXg0ZUvFfX1Fqm14DP6ws=";
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
      rev = "f9052c12ccc26c6d2a67fe94c3f58d8b3f77f1a6";
      hash = "sha256-EZym7ohaisE5nhI4tvaHTSJJQaE9zTiGrNjsCQaZllU=";
    };
    propagatedBuildInputs = [ ppxlib ];
  };
}
