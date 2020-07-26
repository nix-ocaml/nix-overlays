{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let buildDataloader = args: buildDunePackage ({
  version = "0.0.1-dev";

  src = fetchFromGitHub {
    owner = "anmonteiro";
    repo = "ocaml-dataloader";
    rev = "c2e6d7d057d4453b36511a5d293e9ab502755484";
    sha256 = "0d1fx3zzgwl3hdr9kwlnb381d5b8zfc2v8vsvrzpqkwgb77c78kv";
  };
} // args);
in
  {
    dataloader = buildDataloader {
      pname = "dataloader";
    };

    dataloader-lwt = buildDataloader {
      pname = "dataloader-lwt";

      propagatedBuildInputs = [ dataloader lwt ];
    };
  }
