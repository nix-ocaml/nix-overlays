{ ocamlPackages }:

with ocamlPackages;

let buildReasonPkg = args: buildDunePackage ({
  version = "3.6.0";

  src = builtins.fetchurl {
    url = https://github.com/facebook/reason/archive/315af8ebeb1e80f043738950f8c3bfcdc10adc40.tar.gz;
    sha256 = "0rmh2r4087j56qlsxw0jn64iq519xy57ij9g350dv7wk6i9fziji";
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
