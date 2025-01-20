{ buildDunePackage, lib, csexp, merlin-lib, ocaml }:

buildDunePackage {
  pname = "ocaml-index";
  version = "1.0";

  src =
    if lib.versionOlder "5.3" ocaml.version then merlin-lib.src
    else
      builtins.fetchurl {
        url = "https://github.com/voodoos/ocaml-index/releases/download/v1.0/ocaml-index-1.0.tbz";
        sha256 = "070yhxr5rnrk93hxzxy9qmk78x3ka684gbax5w0zfqfm22irrqq1";
      };

  propagatedBuildInputs = [ merlin-lib csexp ];

  postPatch = if lib.versionOlder "5.3" ocaml.version then "" else ''
    substituteInPlace lib/index.ml --replace-fail \
      "Misc_utils.loc_of_decl" "Merlin_analysis.Typedtree_utils.location_of_declaration"
  '';
}
