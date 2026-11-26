{
  lib,
  buildDunePackage,
  dream,
  pure-html,
  ppxlib,
}:

buildDunePackage {
  pname = "dream-html";
  inherit (pure-html) src version;

  postPatch = lib.optionalString (lib.versionOlder ppxlib.version "0.36") ''
    substituteInPlace ppx/ppx.ml \
      --replace-fail "value_binding ~constraint_:drop" "value_binding"
  '';

  propagatedBuildInputs = [
    pure-html
    dream
    ppxlib
  ];

  meta = {
    description = "Write HTML directly in your OCaml source files with editor support.";
    license = lib.licenses.gpl3;
  };
}
