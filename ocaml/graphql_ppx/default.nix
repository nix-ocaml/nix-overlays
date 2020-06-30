{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildGraphQLPPX = { version, rev, sha256 }: buildDunePackage {
    pname = "graphql_ppx";
    inherit version;

    src = fetchFromGitHub {
      owner = "reasonml-community";
      repo = "graphql-ppx";
      inherit rev sha256;
    };

    nativeBuildInputs = [ cppo ];

    propagatedBuildInputs = [
      yojson
      ocaml-migrate-parsetree
      ppx_tools_versioned
      reason
      menhir
    ];
  };
in

  {
    graphql_ppx = buildGraphQLPPX (rec {
      version = "v0.7.1";
      rev = version;
      sha256 = "0gpzwcnss9c82whncyxfm6gwlkgh9hy90329hrazny32ybb470zh";
    });

    # Only works in BuckleScript
    graphql_ppx-1_x = buildGraphQLPPX (rec {
      version = "v1.0.0";
      rev = "84f139fcd4aa74953f4f291c309cf9a8770aff06";
      sha256 = "0v168vvnr9vgcw7m7zl776r1w85gg9ma4rzb3x9a2fv0vk9fzg64";
    });
  }

