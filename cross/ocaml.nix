{ lib, buildPackages, }:

oself: osuper:
let
  fixOCaml = ocaml: ocaml.overrideAttrs (o:
    let
      version = lib.stringAsChars
        (x: if x == "." then "_" else x)
        (builtins.substring 0 4 ocaml.version);
      natocaml =
        buildPackages.ocaml-ng."ocamlPackages_${version}".ocaml;
    in
    {
      preConfigure = ''
        configureFlagsArray+=("CC=$CC" "PARTIALLD=$LD -r" "ASPP=$CC -c" "AS=$AS")
      '';
      configureFlags = o.configureFlags ++ [
        "--disable-ocamldoc"
        "--disable-debugger"
      ];
      preBuild = ''
        buildFlagsArray+=("OCAMLYACC=${natocaml}/bin/ocamlyacc" "CAMLYACC=${natocaml}/bin/ocamlyacc" "CAMLRUN=${natocaml}/bin/ocamlrun" "OCAMLRUN=${natocaml}/bin/ocamlrun" -j16)
      '';
      buildPhase = ''
        runHook preBuild
        make world  "''${buildFlagsArray[@]}" -j16
        make opt "''${buildFlagsArray[@]}" -j16
        runHook postBuild
      '';
      postInstall = ''
        cp ${natocaml}/bin/ocamlrun $out/bin/ocamlrun
      '';
      patches = [ ./cross.patch ];
    });

in
{
  ocaml = fixOCaml osuper.ocaml;

  findlib = osuper.findlib.overrideAttrs (o: {
    configurePlatforms = [ ];
    nativeBuildInputs = o.buildInputs;

    # configureFlags = (o.configureFlags or [ ]) ++ [
    # "-no-custom"
    # "-no-topfind"
    # ];
    # buildPhase = ''
    # make all
    # '';
  });

  dune = osuper.dune.overrideAttrs (o: {
    nativeBuildInputs = with buildPackages;  with oself; [ ocaml findlib ];
    buildInputs = [ ];
  });
}
