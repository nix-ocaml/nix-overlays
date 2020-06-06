{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildGraphQLPPX = { version, rev, sha256 }: buildDunePackage {
    pname = "graphql_ppx";
    inherit version;

    src = fetchFromGitHub {
      owner = "reasonml-community";
      repo = "graphql_ppx";
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
      rev = "3cd0cba974293f9de3b43a8d3595cf98a2b5b072";
      sha256 = "1vn8d02lz5ywd0sdcia030kjwmp47wbkwl3g78i61ys2w24s992n";
    });
  }

