{ buildDunePackage, conan, lwt, bigstringaf }:

buildDunePackage {
  pname = "conan-lwt";
  inherit (conan) version src;
  propagatedBuildInputs = [ conan lwt bigstringaf ];
}
