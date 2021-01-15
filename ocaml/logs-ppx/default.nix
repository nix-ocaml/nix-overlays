{ stdenv, ocamlPackages, lib }:

with ocamlPackages;
let src = builtins.fetchurl {
  url = https://github.com/ulrikstrid/logs-ppx/archive/v0.1.0.tar.gz;
  sha256 = "0j8x81qc7k8p87rrw2nv9wasjjnq4hrfwcwk3a682p90gzdx9vcy";
};

in
{
  logs-ppx = ocamlPackages.buildDunePackage
    {
      pname = "logs-ppx";
      version = "0.1.0";
      inherit src;

      propagatedBuildInputs = with ocamlPackages; [
        ppxlib
      ];

      meta = {
        description = "PPX to cut down on boilerplate when using Logs";
        license = stdenv.lib.licenses.bsd3;
      };
    };
}
