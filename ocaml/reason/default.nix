{ ocamlPackages }:

with ocamlPackages;

let buildReasonPkg = args: buildDunePackage ({
  version = "3.6.0";

  src = builtins.fetchurl {
    url = https://github.com/facebook/reason/archive/7bcfbc38c0eee785b0fdc4b6003ddf62799f084f.tar.gz;
    sha256 = "1v5ipdbs9gwhdp09lx2hrn1jq95ncfd8cyz5xacxg2xq0n2q6qc2";
  };
} // args);

in

{
  reason = buildReasonPkg {
    pname = "reason";

    propagatedBuildInputs = [ menhir fix merlin-extend ppx_derivers result ];

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
