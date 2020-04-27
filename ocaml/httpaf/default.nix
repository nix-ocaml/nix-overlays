{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

let
  buildHttpaf = args: buildDunePackage ({
    version = "0.6.5-dev";
    src = fetchFromGitHub {
      owner = "anmonteiro";
      repo = "httpaf";
      rev = "4e3396c991530c9ae5f9ab36e611448446f21196";
      sha256 = "1npcl1w97l6gi3lhp60ssf8142fqcb1my8p78c662imksk8vk5c7";
    };
  } // args);
in rec {
  httpaf = buildHttpaf {
    pname = "httpaf";
    propagatedBuildInputs = [ angstrom faraday ];
  };

  httpaf-lwt = buildHttpaf {
    pname = "httpaf-lwt";
    propagatedBuildInputs = [ httpaf gluten-lwt lwt4 ];
  };

  httpaf-lwt-unix = buildHttpaf {
    pname = "httpaf-lwt-unix";
    propagatedBuildInputs = [
      httpaf
      httpaf-lwt
      gluten-lwt-unix
      faraday-lwt-unix
      lwt_ssl
    ];
  };
}
