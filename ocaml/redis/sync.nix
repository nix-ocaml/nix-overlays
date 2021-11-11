{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "redis-sync";
  inherit (redis) src version;

  propagatedBuildInputs = [ redis ];

  checkInputs = [ ounit containers ];

  meta = {
    description = "Redis client (blocking)";
    license = lib.licenses.bsd3;
  };
}
