{
  lib,
  stdenv,
  buildDunePackage,
  fetchurl,
  astring,
  eio,
  fmt,
  logs,
  mtime,
  optint,
  cf-lwt,
  fsevents-lwt,
  inotify-eio,
  lwt_eio,
  alcotest,
  eio_main,
}:

buildDunePackage {
  pname = "irmin-watcher";
  version = "0.6.0";
  src = fetchurl {
    url = "https://github.com/mirage/irmin-watcher/releases/download/0.6.0/irmin-watcher-0.6.0.tbz";
    hash = "sha256-4jArwL4H/pzWRK1M5xkUYOpjqrQwnzYN+Qn+GbJPpHc=";
  };
  minimalOCamlVersion = "5.2";
  propagatedBuildInputs = [
    astring
    eio
    fmt
    logs
    mtime
    optint
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cf-lwt
    fsevents-lwt
    lwt_eio
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ inotify-eio ];
  checkInputs = [
    alcotest
    eio_main
    lwt_eio
  ];
  doCheck = true;
  meta = {
    description = "Portable Irmin watch backends using FSEvents or inotify";
    homepage = "https://github.com/mirage/irmin-watcher";
    license = lib.licenses.isc;
    platforms = lib.platforms.all;
  };
}
