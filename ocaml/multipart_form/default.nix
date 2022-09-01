{ upstream ? false
, lib
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
    url = https://github.com/dinosaure/multipart_form/releases/download/v0.4.1/multipart_form-0.4.1.tbz;
    sha256 = "1ns0ans9kd983pcp6rsqrv3aahglm6j7gff0q9rk5if4zvk8w9in";
  };
  upstream_version = "0.4.1";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/multipart_form/archive/958ada0c.tar.gz;
    sha256 = "162m0g6ka21bjbd2j6d69y1hkran5vkssl4ipzqd1lblkrq7mial";
  };
  version = "0.1.0-dev";

in

buildDunePackage {
  pname = "multipart_form";

  version = if upstream then upstream_version else version;

  src = if upstream then upstream_src else src;

  propagatedBuildInputs = [
    base64
    pecu
    rosetta
    rresult
    uutf
    fmt
    angstrom
    bigstringaf
    ke
    logs
    prettym
    unstrctrd
    faraday
  ];

  doCheck = true;
  checkInputs = [ alcotest rosetta ];
}
