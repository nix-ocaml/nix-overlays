{ fetchFromGitHub, stdenv, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "luv";
  version = "0.5.6";
  src = fetchFromGitHub {
    owner = "aantron";
    repo = "luv";
    rev = "0.5.6";
    sha256 = "04k4v6xnmav0l627j8v9bfkwr74qnfmhls7sj50bl2665p35cg8b";
    fetchSubmodules = true;
  };

  propagatedBuildInputs = [ ctypes result ];

  meta = {
    description = "Cross-platform asynchronous I/O and system calls ";
    license = stdenv.lib.licenses.mit;
  };
}
