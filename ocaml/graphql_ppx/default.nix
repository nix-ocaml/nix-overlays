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
      rev = "082fb4df8784e72c195c641b44058cb22ac4a94e";
      sha256 = "1fv3w0syds2fnsxjmhr7al4yiv3zhnaz01pnimffvl1m2ahwlrns";
    });
  }

