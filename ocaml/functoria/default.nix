{ ocamlPackages }:

with ocamlPackages;

let
  buildFunctoria = args: buildDunePackage (rec {
    version = "3.1.0";
    src = builtins.fetchurl {
      url = "https://github.com/mirage/functoria/releases/download/v${version}/functoria-v${version}.tbz";
      sha256 = "15jdqdj1vfi0x9gjydrrnbwzwbzw34w1iir032jrji820xlblky2";
    };
  } // args);
in rec {
  functoria = buildFunctoria {
    pname = "functoria";
    propagatedBuildInputs = [
      cmdliner
      rresult
      astring
      fmt
      ocamlgraph
      logs
      bos
      fpath
      ptime
    ];
  };

  functoria-runtime = buildFunctoria {
    pname = "functoria-runtime";
    propagatedBuildInputs = [
      cmdliner
      fmt
    ];
  };
}

