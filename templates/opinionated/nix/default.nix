{ pkgs
, stdenv
, lib
, nix-filter
, ocamlPackages
, static ? false
, doCheck
,
}:
with ocamlPackages; rec {
  package = buildDunePackage {
    pname = "package";
    version = "1.0.0";

    src = with nix-filter.lib;
      filter {
        # Root of the project relative to this file
        root = ./..;
        # If no include is passed, it will include all the paths.
        include = [
          # Include the "src" path relative to the root.
          "src"
          "test"
          # Include this specific path. The path must be under the root.
          ../package.opam
          ../dune-project
        ];
      };

    checkInputs = [
      # Put test dependencies here
    ];

    propagatedBuildInputs = [
      # Put dependencies here
    ];

    buildInputs = [
      # Put build-time dependencies here
    ];

    inherit doCheck;

    meta = {
      description = "Describe your project here";
      # license = stdenv.lib.licenses.bsd3;
    };
  };
}
