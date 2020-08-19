{ ocamlPackages }:

with ocamlPackages;

let buildReasonPkg = args: buildDunePackage ({
  version = "3.6.0";

  src = builtins.fetchurl {
    url = https://github.com/facebook/reason/archive/286482590c94e27387c008b4b4a4713da9c53c20.tar.gz;
    sha256 = "110lca2v283qqy167zrb76qb7m01cg544fni259k3sj2r3rahwv3";
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
