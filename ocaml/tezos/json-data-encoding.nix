{ ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://gitlab.com/nomadic-labs/json-data-encoding/-/archive/0.9.1/json-data-encoding-0.9.1.tar.gz;
  sha256 = "0dzdpd0pll21lsk474n299zka194n572dk5iwr0m8v93zdna9qrz";
};

in
{
  json-data-encoding = ocamlPackages.buildDunePackage {
    pname = "json-data-encoding";
    version = "0.9.1";
    inherit src;


    propagatedBuildInputs = with ocamlPackages; [
      uri
      crowbar
      alcotest
    ];

    meta = {
      description = "Type-safe encoding to and decoding from JSON";
      license = lib.licenses.mit;
    };
  };

  json-data-encoding-bson = ocamlPackages.buildDunePackage {
    pname = "json-data-encoding-bson";
    version = "0.9.1";
    inherit src;


    propagatedBuildInputs = with ocamlPackages; [
      json-data-encoding
      ocplib-endian
    ];

    meta = {
      description = "Type-safe encoding to and decoding from JSON";
      license = lib.licenses.mit;
    };
  };
}
