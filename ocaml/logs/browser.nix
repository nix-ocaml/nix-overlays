{
  buildDunePackage,
  logs,
  js_of_ocaml-compiler,
}:

# Keep the browser backend separate from the default Logs package.
buildDunePackage {
  pname = "logs-browser";
  inherit (logs) version src meta;

  postPatch = ''
    cat > dune-project <<'EOF'
    (lang dune 3.0)
    (package (name logs-browser))
    EOF
    cat > src/browser/dune <<'EOF'
    (library
      (name logs_browser)
      (public_name logs-browser)
      (libraries logs js_of_ocaml-compiler.runtime))
    EOF
  '';

  propagatedBuildInputs = [
    logs
    js_of_ocaml-compiler
  ];
}
