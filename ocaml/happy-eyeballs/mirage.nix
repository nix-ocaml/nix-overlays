{ buildDunePackage
, happy-eyeballs
, tcpip
, dns-client
}:

buildDunePackage {
  pname = "happy-eyeballs-mirage";
  inherit (happy-eyeballs) src version;

  propagatedBuildInputs = [ happy-eyeballs tcpip dns-client ];
}
