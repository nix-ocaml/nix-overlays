{ upstream ? false
, buildDunePackage
, unstrctrd
, lwt
, prettym
, logs
, ke
, bigstringaf
, astring
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
    url = https://github.com/dinosaure/multipart_form/releases/download/v0.4.0/multipart_form-0.4.0.tbz;
    sha256 = "1q1rgwb8rcc7b44rr1c41x193z2rdnrny23m45ap2mvy36d1vy3r";
  };
  upstream_version = "0.4.0";
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
    bigstringaf
    faraday
    ke
    logs
    prettym
    unstrctrd
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
    substituteInPlace ./lib_lwt/dune --replace " bigarray " " "
  '';

  doCheck = true;
  checkInputs = [ alcotest rosetta ];
}
