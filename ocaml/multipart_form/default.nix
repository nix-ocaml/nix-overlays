{ upstream ? false
, buildDunePackage
, unstrctrd
, lwt
, prettym
, logs
, ke
, bigstringaf
, astring
, mrmime
, faraday
, base64
, pecu
, rosetta
, rresult
, uutf
, fmt
, angstrom
, alcotest
}:

let
  upstream_src = builtins.fetchurl {
    url = https://github.com/dinosaure/multipart_form/releases/download/v0.3.0/multipart_form-v0.3.0.tbz;
    sha256 = "05cbs2fqvyg67nmyfi8cp8bzl3yzkzw1w2az8brdkxcw1cq9xkgl";
  };
  upstream_version = "0.3.0";
  upstream_propagatedBuildInputs = [
    unstrctrd
    lwt
    prettym
    logs
    ke
    bigstringaf
  ];

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/multipart_form/archive/f4ed204.tar.gz;
    sha256 = "18pk9j9w2b7idjppskagn740yjs6c7ly415x884ipnzmm8vpmkz0";
  };
  version = "0.1.0-dev";
  propagatedBuildInputs = [
    astring
    mrmime
    faraday
  ];

in

buildDunePackage {
  pname = "multipart_form";

  version = if upstream then upstream_version else version;

  src = if upstream then upstream_src else src;

  propagatedBuildInputs = ([
    base64
    pecu
    rosetta
    rresult
    uutf
    fmt
    angstrom
  ] ++ (if upstream then upstream_propagatedBuildInputs else propagatedBuildInputs));

  postPatch = ''
    substituteInPlace ./lib/dune --replace "mrmime.prettym" "prettym"
    substituteInPlace ./lib_lwt/dune --replace " bigarray " " "
  '';

  doCheck = true;
  checkInputs = [ alcotest rosetta ];
}
