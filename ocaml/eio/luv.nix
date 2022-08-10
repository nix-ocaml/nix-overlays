{ buildDunePackage, eio, luv, luv_unix, logs, fmt }:

buildDunePackage {
  pname = "eio_luv";
  inherit (eio) version src;

  propagatedBuildInputs = [ eio luv luv_unix logs fmt ];
}
