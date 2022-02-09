{ lib, buildDunePackage, cppo, lwt, react }:

buildDunePackage {
  pname = "lwt_react";
  version = "1.1.5";
  inherit (lwt) src;

  buildInputs = [ cppo ];

  propagatedBuildInputs = [ lwt react ];

  meta = {
    description = "Helpers for using React with Lwt";
    license = lib.licenses.mit;
  };
}
