{ buildDunePackage, zarith }:

buildDunePackage {
  pname = "decimal";
  version = "1.0.0";
  src = builtins.fetchurl {
    url = https://github.com/yawaramin/ocaml-decimal/releases/download/v1.0.1/decimal-1.0.1.tbz;
    sha256 = "1yagcm207s32cqp9jm3460p1ra1fa7l2zfp65gcsy0bkciyxi5wj";
  };

  propagatedBuildInputs = [ zarith ];
}
