{
  oself,
  fetchFromGitHub,
  lib,
}:

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
    propagatedBuildInputs = [
      melange
      melange-json
    ];
  };

  melange-fetch = buildDunePackage {
    pname = "melange-fetch";
    version = "n/a";
    src = builtins.fetchurl {
      url = "https://github.com/melange-community/melange-fetch/releases/download/0.2.0/melange-fetch-0.2.0.tbz";
      sha256 = "1vv52s0sld3jpi7awrfhh6lxqk39nb50zhc6gqbl76yinfvmnb69";
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
      rev = "e986b2c764881842d6920fc0bcaf01c3076acb51";
      hash = "sha256-EvBPTCTeSAYXlFr3dSt9zeAoKRx5rxkdR+O2VzEADts=";
    };
    nativeBuildInputs = [
      melange
      reason
    ];
    propagatedBuildInputs = [
      melange
      reason-react
    ];
  };

  melange-testing-library = buildDunePackage {
    pname = "melange-testing-library";
    version = "n/a";
    src = builtins.fetchurl {
      url = "https://github.com/melange-community/melange-testing-library/releases/download/0.2.0/melange-testing-library-0.2.0.tbz";
      sha256 = "0kargnsn42yxcfqr8j5yx8jbb36m5liqzcbr1riqbygfkbi2s690";
    };
    nativeBuildInputs = [
      melange
      reason
    ];
    propagatedBuildInputs = [
      melange
      reason-react
    ];
  };

  melange-json = buildDunePackage {
    inherit (melange-json-native) version src;
    pname = "melange-json";
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [
      melange
      ppxlib_gt_0_37
    ];
  };

  melange-jest = buildDunePackage {
    pname = "melange-jest";
    version = "n/a";
    src = builtins.fetchurl {
      url = "https://github.com/melange-community/melange-jest/releases/download/0.2.0/melange-jest-0.2.0.tbz";
      sha256 = "05w0hbwacv588qn7c751jyyhy1prrkcic6gnxpqzs23wqfy15v64";
    };
    nativeBuildInputs = [ melange ];
    propagatedBuildInputs = [
      melange
      reason-react
    ];
  };

  melange-numeral = buildDunePackage {
    pname = "melange-numeral";
    version = "0.0.1";
    src = builtins.fetchurl {
      url = "https://github.com/ahrefs/melange-numeral/releases/download/0.0.1/melange-numeral-0.0.1.tbz";
      sha256 = "1a16j014ps835xqks7mgybqqq34rpvhnzbibrh1pypcqa7hhcdnd";
    };
    nativeBuildInputs = [
      melange
      reason
    ];
    propagatedBuildInputs = [ melange ];
  };

  melange-webapi = buildDunePackage {
    pname = "melange-webapi";
    version = "n/a";
    src = builtins.fetchurl {
      url = "https://github.com/melange-community/melange-webapi/releases/download/0.22.0/melange-webapi-0.22.0.tbz";
      sha256 = "01xy8xz1wl00v8ny4g83czv3hspiv6qi7hym5kmv5v4xc4g6gv27";
    };
    nativeBuildInputs = [
      melange
      reason
    ];
    propagatedBuildInputs = [
      melange
      melange-fetch
    ];
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

  react-rules-of-hooks-ppx = buildDunePackage {
    pname = "react-rules-of-hooks-ppx";
    version = "1.0.0";
    src = builtins.fetchurl {
      url = "https://github.com/ml-in-barcelona/react-rules-of-hooks-ppx/releases/download/1.0.0/react-rules-of-hooks-ppx-1.0.0.tbz";
      sha256 = "12413bab8wa0982kcw9xxnqws9h7bswa1d8d93qhabrcyfhdqzvb";
    };
    propagatedBuildInputs = [ ppxlib_gt_0_37 ];
  };

  reason-react = buildDunePackage {
    pname = "reason-react";
    inherit (reason-react-ppx) src version;
    nativeBuildInputs = [
      reason
      melange
    ];
    propagatedBuildInputs = [
      reason-react-ppx
      melange
    ];
  };

  reason-react-ppx = buildDunePackage {
    pname = "reason-react-ppx";
    version = "0.17.0";
    src = builtins.fetchurl {
      url = "https://github.com/reasonml/reason-react/releases/download/0.17.0/reason-react-0.17.0.tbz";
      sha256 = "131izysadis4k3y78kwhx7mva1pd2zs9xihv7jcc33alpl47mdh2";
    };
    propagatedBuildInputs = [ ppxlib_gt_0_37 ];
  };
}
