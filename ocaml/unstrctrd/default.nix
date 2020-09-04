{ ocamlPackages }:

with ocamlPackages;

buildDunePackage rec {
  pname = "unstrctrd";
  version = "0.2.0";
  src = builtins.fetchurl {
    url = https://github.com/dinosaure/unstrctrd/releases/download/v0.2/unstrctrd-v0.2.tbz;
    sha256 = "0yb9n7zrdvcsawwjj9dxfwqc9gq12bmaynnfyjm5yd0s876vyh0h";
  };

  propagatedBuildInputs = [
    angstrom
    uutf
  ];
}
