{ ocamlPackages, lib }:

with ocamlPackages;

buildDunePackage {
  pname = "caqti-lwt";
  useDune2 = true;
  inherit (caqti) version src;

  propagatedBuildInputs = [ caqti logs lwt ];

  meta = caqti.meta // { description = "Lwt support for Caqti"; };
}
