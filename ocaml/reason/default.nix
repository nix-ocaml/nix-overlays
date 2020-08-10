{ ocamlPackages }:

with ocamlPackages;

let buildReasonPkg = args: buildDunePackage ({
  version = "3.6.0";

  src = builtins.fetchurl {
    url = https://github.com/facebook/reason/archive/932f1b641a729ea17fa5ae2597b046721f448cc2.tar.gz;
    sha256 = "0rvfypiyxjr69i28x3ijgqn9mym65dfcdk4hgay699xw4q2l6jcb";
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
