{ buildDunePackage, ppx_inline_test, ppx_deriving, ctypes, ctypes-foreign }:

buildDunePackage {
  pname = "pg_query";
  version = "0.9.7";

  unpackPhase = ''
    runHook preUnpack
    tar -xzf $src --strip-components=1 --exclude='bin'
    runHook postUnpack
  '';

  src = builtins.fetchurl {
    url = https://github.com/roddyyaga/pg_query-ocaml/archive/0.9.7.tar.gz;
    sha256 = "04hzmx5hml9c1nlcpjx1wcfgi7lalir0qk2xx9m7ljfwhw469fhc";
  };
  postPatch = ''
    substituteInPlace lib/dune --replace "ctypes.foreign" "ctypes-foreign"
  '';

  useDune2 = true;

  propagatedBuildInputs = [ ppx_inline_test ppx_deriving ctypes ctypes-foreign ];
}
