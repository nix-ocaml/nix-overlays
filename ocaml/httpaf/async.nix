{ ocamlPackages, ocamlVersion, lib }:

with ocamlPackages;

if (lib.versionOlder "4.08" ocamlVersion) then
  buildDunePackage
  {
    inherit (httpaf) version src;
    pname = "httpaf-async";
    doCheck = false;
    propagatedBuildInputs = [
      httpaf
      async
      gluten-async
      faraday-async
      async_ssl
    ];
  }
else null
