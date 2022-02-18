{ lib, buildDunePackage, rock, lwt, httpaf-lwt-unix, logs, fmt, mtime, cmdliner, ptime, magic-mime, yojson, tyxml, mirage-crypto, base64, astring, re, uri, multipart-form-data, result }:

buildDunePackage {
  pname = "opium";
  inherit (rock) src version;

  propagatedBuildInputs = [ rock lwt httpaf-lwt-unix logs fmt mtime cmdliner ptime magic-mime yojson tyxml mirage-crypto base64 astring re uri multipart-form-data result ];

  meta = {
    description = "OCaml web framework";
    license = lib.licenses.mit;
  };
}
