{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildFaraday = args: buildDunePackage ({
    version = "0.12.0-dev";

    src = fetchFromGitHub {
      owner = "inhabitedtype";
      repo = "faraday";
      rev = "8d37f20";
      sha256 = "1g9k5lyg6qck375l29dsid0q24i8j6m0jhsxrf460w2gxm4xl754";
    }; } // args);
in rec {
  faraday = buildFaraday {
    pname = "faraday";
    propagatedBuildInputs = [ bigstringaf ];
  };

  faraday-lwt = buildFaraday {
    pname = "faraday-lwt";
    propagatedBuildInputs = [ faraday lwt ];
  };

  faraday-lwt-unix = buildFaraday {
    pname = "faraday-lwt-unix";
    propagatedBuildInputs = [ faraday-lwt ];
  };

  faraday-async = buildFaraday {
    pname = "faraday-async";
    propagatedBuildInputs = [ faraday async ];
  };
}
