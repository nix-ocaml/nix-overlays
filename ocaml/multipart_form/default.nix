{ ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "multipart_form";

  version = "0.1.0-dev";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/multipart_form/archive/6ad738e423d53c53ab494d6e6526f42140db1098.tar.gz;
    sha256 = "1w2bzpvsc1i6ifi9jmcgz2f8shnfgdmrkzh1jj3mj2dlqcgpipxx";
  };

  doCheck = true;
  checkInputs = [ alcotest ];

  propagatedBuildInputs = [
    astring
    base64
    mrmime
    faraday
    pecu
    rosetta
    rresult
    uutf
    fmt
    angstrom
  ];
}
