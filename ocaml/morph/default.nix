{ stdenv, ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://github.com/reason-native-web/morph/archive/64049af8d77a3fb6830e64bbf818931c5f9fef9c.tar.gz;
  sha256 = "10v5s3as6vsvm8vdz5bjywqiar6wzb83c63zyddbb69c3hgyqyqa";
};

in
{
  morph = ocamlPackages.buildDunePackage {
    pname = "morph";
    version = "0.6.2-dev";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      reason
      fmt
      hmap
      logs
      lwt
      piaf
      session
      cookie
      digestif
      session-cookie
      session-cookie-lwt
      magic-mime
      uri
      routes
    ];

    meta = {
      description = "Webframework for Reason and OCaml.";
      license = stdenv.lib.licenses.mit;
    };
  };

  morph_graphql_server = ocamlPackages.buildDunePackage {
    pname = "morph_graphql_server";
    version = "0.6.2-dev";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      reason
      logs
      lwt
      morph
      graphql
      graphql-lwt
    ];

    meta = {
      description = "Helpers for working with graphql and morph";
      license = stdenv.lib.licenses.mit;
    };
  };

  morph_websocket = ocamlPackages.buildDunePackage {
    pname = "morph_websocket";
    version = "0.6.2-dev";
    inherit src;

    propagatedBuildInputs = with ocamlPackages; [
      logs
      lwt
      digestif
      morph
      graphql
      graphql-lwt
      morph_graphql_server
      websocketaf
      subscriptions-transport-ws
    ];

    meta = {
      description = "Helpers for working with graphql and morph";
      license = stdenv.lib.licenses.mit;
      broken = true;
    };
  };
}
