{ ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://gitlab.com/nomadic-labs/resto/-/archive/v0.6.1/resto-v0.6.1.tar.gz;
  sha256 = "0i76c9wfnf4k0hmz42kw04q1si4zij6ly4r0apiy4r9ymi8xk36m";
};

in
{
  resto = ocamlPackages.buildDunePackage {
    pname = "resto";
    version = "0.6.1";
    inherit src;

    # doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      uri
      json-data-encoding
      json-data-encoding-bson
      ezjsonm
      lwt
      # base-unix
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };

  resto-json = ocamlPackages.buildDunePackage {
    pname = "resto-json";
    version = "0.6.1";
    inherit src;

    # doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      resto
      json-data-encoding
      json-data-encoding-bson
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };

  resto-directory = ocamlPackages.buildDunePackage {
    pname = "resto-directory";
    version = "0.6.1";
    inherit src;

    # doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      resto
      resto-json
      lwt
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };

  resto-acl = ocamlPackages.buildDunePackage {
    pname = "resto-acl";
    version = "0.6.1";
    inherit src;

    # doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      uri
      resto
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };

  resto-cohttp = ocamlPackages.buildDunePackage {
    pname = "resto-cohttp";
    version = "0.6.1";
    inherit src;

    checkInputs = [
      resto-acl
    ];

    #doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      resto-directory
      cohttp-lwt
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };

  ezresto = ocamlPackages.buildDunePackage {
    pname = "ezresto";
    version = "0.6.1";
    inherit src;

    checkInputs = [
      lwt
      # base-unix
    ];

    # doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      uri
      resto
      resto-json
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };

  ezresto-directory = ocamlPackages.buildDunePackage {
    pname = "ezresto-directory";
    version = "0.6.1";
    inherit src;

    checkInputs = [
      resto-acl
    ];

    # doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      ezresto
      resto-directory
      resto
      lwt
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };

  resto-cohttp-self-serving-client = ocamlPackages.buildDunePackage {
    pname = "resto-cohttp-self-serving-client";
    version = "0.6.1";
    inherit src;

    checkInputs = [
    ];

    # doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      uri
      resto-cohttp-client
      resto-cohttp-server
      cohttp-lwt
      lwt
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };

  resto-cohttp-client = ocamlPackages.buildDunePackage rec {
    pname = "resto-cohttp-client";
    version = "0.6.1";
    inherit src;

    checkInputs = with ocamlPackages; [
      resto-cohttp-server
      ezresto-directory
      resto-cohttp-self-serving-client
    ];

    # doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      uri
      resto-cohttp
      cohttp-lwt
      lwt
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };

  resto-cohttp-server = ocamlPackages.buildDunePackage rec {
    pname = "resto-cohttp-server";
    version = "0.6.1";
    inherit src;

    # doCheck = true;

    propagatedBuildInputs = with ocamlPackages; [
      resto-directory
      resto-cohttp
      resto-acl
      cohttp-lwt-unix
      conduit-lwt-unix
      lwt
    ];

    meta = {
      description = "A minimal OCaml library for type-safe HTTP/JSON RPCs";
      license = lib.licenses.mit;
    };
  };
}
