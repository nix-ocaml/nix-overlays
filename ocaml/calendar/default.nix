{ fetchFromGitHub, ocamlPackages }:

with ocamlPackages;

buildDunePackage {
  pname = "calendar";
  version = "3.0-dev";
  src = fetchFromGitHub {
    owner = "ocaml-community";
    repo = "calendar";
    rev = "26a8c3d7667d49698fb5c7d1d464924aa7476a1d";
    sha256 = "1qnm53h0xbxydqxd8gmkgl54w0vk646b2q6cr5bfpkxbj3r48gvb";
  };

  buildInputs = [ alcotest ];

  propagatedBuildInputs = [ re ];
}
