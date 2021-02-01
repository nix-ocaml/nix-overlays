{ ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://github.com/ulrikstrid/ocaml-cookie/archive/95592ac37dc9209cf4f07544156aad7c3187dbab.tar.gz;
  sha256 = "02rmanzjbxps2ax3546pd3jpzx88kcb9zlyyza920fvnavhk3g10";
};

in
{
  cookie = ocamlPackages.buildDunePackage
    {
      pname = "cookie";
      version = "0.1.8-dev";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        uri
        ptime
        astring
      ];

      meta = {
        description = "Cookie parsing and serialization for OCaml";
        license = lib.licenses.bsd3;
      };
    };

  session-cookie = ocamlPackages.buildDunePackage
    {
      pname = "session-cookie";
      version = "0.1.8-dev";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        cookie
        session
      ];

      meta = {
        description = "Session handling based on Cookie parsing and serialization for OCaml";
        license = lib.licenses.bsd3;
      };
    };

  session-cookie-lwt = ocamlPackages.buildDunePackage
    {
      pname = "session-cookie-lwt";
      version = "0.1.8-dev";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        session-cookie
        lwt
      ];

      meta = {
        description = "Session handling based on Cookie parsing and serialization for OCaml";
        license = lib.licenses.bsd3;
      };
    };
}
