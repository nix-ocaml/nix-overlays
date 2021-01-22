{ stdenv, ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://github.com/0xffea/ocaml-redis/archive/0.4.tar.gz;
  sha256 = "1xia2dm0sr3mqlic1hvkglnv03ndbfxv18bhi2mfzpgpjcd9yl9a";
};

in
{
  redis = ocamlPackages.buildDunePackage
    {
      pname = "redis";
      version = "0.4";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        uuidm
        re
      ];

      meta = {
        description = "Redis client";
        license = stdenv.lib.licenses.bsd3;
      };
    };

  redis-lwt = ocamlPackages.buildDunePackage
    {
      pname = "redis-lwt";
      version = "0.4";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        redis
        lwt
      ];

      buildInputs = with ocamlPackages; [
        ounit
        containers
      ];

      meta = {
        description = "Redis client (lwt interface)";
        license = stdenv.lib.licenses.bsd3;
      };
    };

  redis-sync = ocamlPackages.buildDunePackage
    {
      pname = "redis-sync";
      version = "0.4";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        redis
      ];

      buildInputs = with ocamlPackages; [
        ounit
        containers
      ];

      meta = {
        description = "Redis client (blocking)";
        license = stdenv.lib.licenses.bsd3;
      };
    };
}
