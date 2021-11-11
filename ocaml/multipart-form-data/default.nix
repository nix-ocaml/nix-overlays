{ buildDunePackage, lwt, lwt_ppx, stringext }:

buildDunePackage rec {
  pname = "multipart-form-data";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/cryptosense/multipart-form-data/archive/refs/tags/0.3.0.tar.gz;
    sha256 = "1g92ylnmz5qjb1yq2j5f8zbllyxqzdv0qxaf8n78skd5094zpjyy";
  };

  propagatedBuildInputs = [
    lwt
    lwt_ppx
    stringext
  ];
}
