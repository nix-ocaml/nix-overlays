{ lib, buildDunePackage, ppxlib }:

buildDunePackage rec {
  pname = "logs-ppx";
  version = "0.2.0";
  src = builtins.fetchurl {
    url = "https://github.com/ulrikstrid/${pname}/releases/download/v${version}/logs-ppx-${version}.tbz";
    sha256 = "1cdzq08c54b93ysw94ykhnb51h8sx61b9sh3jl3xrmjrz4z08gq5";
  };

  doCheck = true;

  propagatedBuildInputs = [ ppxlib ];

  meta = {
    description = "PPX to cut down on boilerplate when using Logs";
    license = lib.licenses.bsd3;
  };
}
