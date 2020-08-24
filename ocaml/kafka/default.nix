{ ocamlPackages, rdkafka, zlib }:

with ocamlPackages;

let buildKafka = args: buildDunePackage (rec {
    version = "0.5.0";
    src = builtins.fetchurl {
      url = https://github.com/didier-wenzek/ocaml-kafka/releases/download/0.5/kafka-0.5.tbz;
      sha256 = "0m9212yap0a00hd0f61i4y4fna3141p77qj3mm7jl1h4q60jdhvy";
    };
  } // args);

in

  {
    kafka = buildKafka {
      pname = "kafka";
      propagatedBuildInputs = [ rdkafka zlib ];
    };

    kafka_lwt = buildKafka {
      pname = "kafka_lwt";
      propagatedBuildInputs = [ kafka lwt cmdliner ];
    };

    kafka_async = buildKafka {
      pname = "kafka_async";
      propagatedBuildInputs = [ kafka async ];
    };
  }

