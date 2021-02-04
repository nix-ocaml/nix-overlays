{ ocamlPackages, ocamlVersion, lib }:

with ocamlPackages;

if (lib.versionOlder "4.08" ocamlVersion) then
  buildDunePackage
  {
    inherit (httpaf) version src;
    pname = "httpaf-mirage";
    doCheck = false;
    propagatedBuildInputs = [
      conduit-mirage
      httpaf-lwt
      gluten-mirage
    ];
  }
else null
