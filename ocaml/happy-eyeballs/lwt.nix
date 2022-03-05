{ buildDunePackage
, happy-eyeballs
, lwt
, dns-client
}:

buildDunePackage {
  pname = "happy-eyeballs-lwt";
  inherit (happy-eyeballs) version src;

  propagatedBuildInputs = [ happy-eyeballs lwt dns-client ];
}
