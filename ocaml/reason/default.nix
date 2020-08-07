{ ocamlPackages }:

with ocamlPackages;

let buildReasonPkg = args: buildDunePackage ({
  version = "3.6.0";

  src = builtins.fetchurl {
    url = https://github.com/facebook/reason/archive/48027c3c66cf692827a237f2235ad540d5f92d58.tar.gz;
    sha256 = "1h37lv9js6kfdnsrklsd9g047gcckhwxy9pfaii8rn3kw10avs78";
  };
} // args);

in

{
  reason = buildReasonPkg {
    pname = "reason";

    propagatedBuildInputs = [ menhir fix merlin-extend ocaml-migrate-parsetree ];

    buildInputs = [ cppo menhir ];

    patches = [
      ./patches/0001-rename-labels.patch
    ];
  };

  rtop = buildReasonPkg {
    pname = "rtop";
    buildInputs = [ cppo ];
    propagatedBuildInputs = [ utop reason ];
  };
}
