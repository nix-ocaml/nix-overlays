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
      rev = "40813dc038f7b54d5e897964f4116d6708016153";
      sha256 = "1ijzbbprhvlwqzpmw3f61pwwbjw64yyv4yvrzag70bxn82g79xfj";
    });
  }

