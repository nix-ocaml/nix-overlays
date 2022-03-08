{ stdenv
, opaline
, buildDunePackage
, cppo
, cmdliner
, dune-action-plugin
, melange-compiler-libs
, reason
, lib
, ocaml
}:

let
  is_412 =
    lib.versionOlder "4.12" ocaml.version &&
    !(lib.versionOlder "4.13" ocaml.version);

in

if is_412
then
  buildDunePackage
  rec {
    pname = "melange";
    version = "0.0.0";

    src = builtins.fetchurl {
      url = https://github.com/melange-re/melange/archive/f7e378b.tar.gz;
      sha256 = "1d8n1xac9wv4qk12rqyfb9y8r30hf9c7ask2hjyhnripyjzyy4dc";
    };

    nativeBuildInputs = [ cppo ];

    propagatedBuildInputs = [
      cmdliner
      dune-action-plugin
      melange-compiler-libs
      reason
    ];

    installPhase = ''
      runHook preInstall
      ${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR

      cp package.json bsconfig.json $out
      cp -r ./_build/default/lib/es6 ./_build/default/lib/js $out/lib

      mkdir -p $out/lib/melange
      cd $out/lib/melange

      tar xvf $OCAMLFIND_DESTDIR/melange/libocaml.tar.gz
      mv others/* .
      mv runtime/* .
      mv stdlib-412/stdlib_modules/* .
      mv stdlib-412/* .
      rm -rf others runtime stdlib-412

      runHook postInstall
    '';
  }
else null
