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
      rev = "1c27b83f3f60360db6f8b85ed7a1d3ef3bb5773b";
      sha256 = "0fxb40q5n0qzkp86g2dpk5nhh2bgsdr4y3aj0amm6vk5q7kyd1sr";
    });
  }

