{ buildDunePackage, bigstringaf, faraday, ke }:

buildDunePackage {
  pname = "gluten";
  version = "0.3.0";

  src = builtins.fetchurl {
    url = https://github.com/anmonteiro/gluten/archive/29de1f333.tar.gz;
    sha256 = "1glbb7wbs2s4q7dddr8s4ziz12qh9bkc8dg4v4lkc8p9dvllhvw1";
  };
  propagatedBuildInputs = [ bigstringaf faraday ke ];
}
