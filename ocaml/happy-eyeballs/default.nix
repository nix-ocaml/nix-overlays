{ buildDunePackage
, logs
, duration
, fmt
, domain-name
, ipaddr
}:

buildDunePackage {
  pname = "happy-eyeballs";
  version = "0.1.3";

  src = builtins.fetchurl {
    url = https://github.com/roburio/happy-eyeballs/releases/download/v0.1.3/happy-eyeballs-0.1.3.tbz;
    sha256 = "0ns1bxcmx0rkq4am6vl2aargdzkfhria8sfmgnh8dgzvvj93cc1c";
  };

  propagatedBuildInputs = [ logs duration fmt domain-name ipaddr ];
}
