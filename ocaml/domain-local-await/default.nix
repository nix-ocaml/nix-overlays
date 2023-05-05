{ buildDunePackage }:

buildDunePackage {
  pname = "domain-local-await";
  version = "";
  src = builtins.fetchurl {
    url = https://github.com/ocaml-multicore/domain-local-await/releases/download/0.1.0/domain-local-await-0.1.0.tbz;
    sha256 = "17a604kjgf8677h8r0vvbymfybj15vh4bw8b6c5h2c30cijzw97h";
  };
}
