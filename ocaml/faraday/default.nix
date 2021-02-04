{ ocamlPackages }:

with ocamlPackages;
let
  buildFaraday = args: buildDunePackage ({
    version = "0.7.2-dev";

    src = builtins.fetchurl {
      url = https://github.com/inhabitedtype/faraday/archive/cc3e6316858117497fbba77bfd5860d6516136c4.tar.gz;
      sha256 = "068am5gg8q7fdcwscqc7lrm8zvna9g5ds0rbzdc7bynljs7y4ys7";
    };
  } // args);
in
{
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
    propagatedBuildInputs = [ faraday async core ];
  };
}
