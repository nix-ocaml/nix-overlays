{ ocamlPackages }:

with ocamlPackages;

let
  buildFaraday = args: buildDunePackage ({
    version = "0.12.0-dev";

    src = builtins.fetchurl {
      url = https://github.com/inhabitedtype/faraday/archive/89ee69331d116ee2962b055ac319cbec66241931.tar.gz;
      sha256 = "1bv84hn806rc4jhg45fd1si1kxyc3gbyl05fyggc4pmyk66qyhm7";
    }; } // args);
in {
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
