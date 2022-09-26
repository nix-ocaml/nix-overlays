{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/31e5abf.tar.gz;
    sha256 = "0v169af5kkbcczbgh801wp0rnh9h3czprhf4l0cdipnqmcrkamv6";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
