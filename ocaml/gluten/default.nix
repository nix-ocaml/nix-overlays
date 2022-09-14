{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/1ba9264df.tar.gz;
    sha256 = "1yfrj1m8ydznya680l8a5dbmjl7z8d0lf9xxsahd1217hblla3yf";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
