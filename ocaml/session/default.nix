{ stdenv, ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://github.com/inhabitedtype/ocaml-session/archive/6180413996e8c95bd78a9afa1431349a42c95588.tar.gz;
  sha256 = "11gs6jybbvyvdndpxi4q4z60ncvza1b4v67qk4fm4xrj7y2im4fs";
};

in
{
  session = ocamlPackages.buildDunePackage
    {
      pname = "session";
      version = "0.5.0-dev";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        mirage-crypto
        mirage-crypto-rng
        base64
      ];

      meta = {
        description = "A session manager for your everyday needs";
        license = stdenv.lib.licenses.bsd3;
      };
    };

  session-redis-lwt = ocamlPackages.buildDunePackage
    {
      pname = "session-redis-lwt";
      version = "0.5.0-dev";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        redis-lwt
        session
      ];

      meta = {
        description = "A session manager for your everyday needs - Redis-specific support for Lwt";
        license = stdenv.lib.licenses.bsd3;
      };
    };
}
