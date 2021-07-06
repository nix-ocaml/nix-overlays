{ ocamlPackages }:

with ocamlPackages;
let buildReasonPkg = args: buildDunePackage ({
  version = "3.7.0";

  src = builtins.fetchurl {
    url = https://registry.npmjs.org/@esy-ocaml/reason/-/reason-3.7.0.tgz;
    sha256 = "0spqbsphxnpp3jdy4amfgw58w6mam5gb4vn9gxm5nh9rkcz0iaqg";
  };
} // args);

in
{
  reason = buildReasonPkg {
    pname = "reason";

    propagatedBuildInputs = [ menhir menhirLib menhirSdk fix merlin-extend ppx_derivers result ];

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
