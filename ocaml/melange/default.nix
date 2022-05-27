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

  melange412Deps = [
    dune-action-plugin
  ];
in

buildDunePackage {
  pname = "melange";
  version = "0.0.0";

  src =
    if is_412 then
      builtins.fetchurl
        {
          url = https://github.com/melange-re/melange/archive/434941c.tar.gz;
          sha256 = "16grqf0r1l8yxdxyp6halbfl1h039911743wbbwgly8wa2di06m4";
        } else
      builtins.fetchurl {
        url = https://github.com/melange-re/melange/archive/f59cc50.tar.gz;
        sha256 = "1kinsiap725h5gwj663zp52jj95m297bqhhr0r937shj08jyim6c";
      };

  nativeBuildInputs = [ cppo ];

  propagatedBuildInputs =
    [ cmdliner melange-compiler-libs reason ]
    ++ lib.optionals is_412 melange412Deps;

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
