{ ocamlPackages, lib }:

with ocamlPackages;
{
  lwt-watcher = ocamlPackages.buildDunePackage {
    pname = "lwt-watcher";
    version = "0.1.0";
    src = builtins.fetchurl {
      url = https://gitlab.com/nomadic-labs/lwt-watcher/-/archive/v0.1/lwt-watcher-v0.1.tar.gz;
      sha256 = "0nml1ikxbc7c56b8vh27sj9lbpxlkhlpfi5mz8jmwf7lc4k22055";
    };

    propagatedBuildInputs = with ocamlPackages; [
      lwt
    ];

    meta = {
      description = "One-to-many broadcast in Lwt";
      license = lib.licenses.mit;
    };
  };

  lwt-exit = ocamlPackages.buildDunePackage {
    pname = "lwt-exit";
    version = "1.0.0";
    src = builtins.fetchurl {
      url = https://gitlab.com/nomadic-labs/lwt-exit/-/archive/1.0/lwt-exit-1.0.tar.gz;
      sha256 = "1p0z6qy40a6r5av9xdygm6znirw30zqg6fnq9bqja339f3spv4sp";
    };

    propagatedBuildInputs = with ocamlPackages; [
      # base-unix
      lwt
      ptime
    ];

    meta = {
      description = "An opinionated clean-exit and signal-handling library for Lwt programs";
      license = lib.licenses.mit;
    };
  };
}
